local generateUUID = require(script.Parent.generateUUID)
local Scope = require(script.Parent.Scope)
local Cryo = require(script.Parent.Cryo)
local Parsers = require(script.Parent.Parsers)

local API_VERSION = 1
local DEFAULT_BREADCRUMBS = 30
local MAX_BREADCRUMBS = 100

local Hub = {
	_client = nil,
	_stack = {Scope.new()},
	_lastEventId = nil
}

function Hub.bindClient(client)
	if Hub._client then
		warn("Can only bind client once")
		return
	end
	Hub._client = client
end

function Hub.getClient()
	return Hub._client
end

function Hub.getStackTop()
	return Hub._stack[#Hub._stack]
end

function Hub.pushScope()
	local stack = Hub._stack
	local parentScope = stack[#stack]
	local scope = Scope.clone(parentScope)
	stack[#stack + 1] = scope
	return scope
end

function Hub.popScope()
	local top = Hub.getStackTop()
	Hub._stack[#Hub._stack] = nil
	return top ~= nil
end

function Hub.withScope(callback)
	local scope = Hub.pushScope()
	pcall(callback, scope)
	Hub.popScope()
end

function Hub.captureException(exceptionString, hint)
	local eventId = generateUUID()
	Hub._lastEventId = eventId

	local hintExtra = {}
	if not Parsers.extractStackFromTrace(exceptionString) then
		-- 1 (here) -> 2 (Static API) -> 3 (original call site)
		local trace = debug.traceback(exceptionString, 3)
		hintExtra = {
			originalException = exceptionString,
			extraTrace = trace
		}
	end

	local finalHint = Cryo.Dictionary.join(hintExtra, hint or {})

	finalHint.event_id = eventId

	Hub.getClient().captureException(exceptionString, finalHint, Hub.getStackTop())

	return eventId
end

function Hub.captureMessage(message, level, hint)
	local eventId = generateUUID()
	Hub._lastEventId = eventId
	local finalHint = hint

	if not hint then
		-- 1 (here) -> 2 (Static API) -> 3 (original call site)
		local trace = debug.traceback(message, 3)
		finalHint = {
			originalException = message,
			extraTrace = trace
		}
	end

	finalHint.event_id = eventId

	Hub.getClient().captureMessage(message, level, finalHint, Hub.getStackTop())

	return eventId
end

function Hub.captureEvent(event, hint)
	local eventId = generateUUID()
	Hub._lastEventId = eventId

	hint = hint or {}
	hint.event_id = eventId

	Hub.getClient().captureEvent(event, hint, Hub.getStackTop())

	return eventId
end

function Hub.lastEventId()
	return Hub._lastEventId
end

return Hub