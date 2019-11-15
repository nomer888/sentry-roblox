local generateUUID = require(script.Parent.generateUUID)
local Dsn = require(script.Parent.Dsn)
local Version = require(script.Parent.Version)
local Transport = require(script.Parent.Transport)
local Parsers = require(script.Parent.Parsers)
local Cryo = require(script.Parent.Cryo)

local Client = {
	_options = nil,
	_processing = false,
	_dsn = nil
}

function Client.init(options)
	Client._options = options
	Client._transport = Transport.new(options)
	if options.dsn then
		Dsn.fromString(options.dsn)
		Client._dsn = Dsn
	end
	if Client._isEnabled() then
		-- TODO integrations
	end
end

function Client.captureException(exception, hint, scope)
	local eventId = hint and hint.event_id

	Client._processing = true

	local event = {
		event_id = eventId,
		-- message = Parsers.extractMessageFromTrace(exception),
		exception = {
			type = "Error",
			value = Parsers.extractMessageFromTrace(exception),
			stacktrace = {
				frames = Parsers.extractStackFromTrace(exception)
			}
		}
	}

	if Client._options.attachStacktrace and hint and hint.extraTrace then
		local stack = Parsers.extractStackFromTrace(hint.extraTrace)
		event.stacktrace = {
			frames = stack
		}
	end

	if not next(event.exception.stacktrace) then
		event.exception.stacktrace = nil
	end

	local finalEvent = Client._processEvent(event, hint, scope)
	eventId = finalEvent.event_id
	Client._processing = false

	return event
end

function Client.captureMessage(message, level, hint, scope)
	local eventId = hint and hint.event_id

	Client._processing = true

	local event = {
		event_id = hint and hint.event_id,
		level = level,
		message = message
	}

	if Client._options.attachStacktrace and hint and hint.extraTrace then
		local stack = Parsers.extractStackFromTrace(hint.extraTrace)
		event.stacktrace = {
			frames = stack
		}
	end

	local finalEvent = Client._processEvent(event, hint, scope)
	eventId = finalEvent.event_id
	Client._processing = false

	return eventId
end

function Client.captureEvent(event, hint, scope)
	Client._processing = true

	local finalEvent = Client._processEvent(event, hint, scope)
	local eventId = finalEvent.event_id
	Client._processing = false

	return eventId
end

function Client.getDsn()
	return Client._dsn
end

function Client.getOptions()
	return Client._options
end

function Client._isEnabled()
	return Client.getOptions().enabled ~= false and Client.getDsn() ~= nil
end

function Client._processEvent(event, hint, scope)
	if not Client._isEnabled() then
		return
	end
	local prepared = Client._prepareEvent(event, hint, scope)
	local success, result = pcall(function()
		Client._transport:_sendEvent(prepared)
	end)
	if not success then
		warn(result)
	end
	return prepared
end

function Client._prepareEvent(event, hint, scope)
	event.platform = "other"
	event.sdk = Cryo.Dictionary.join(event.sdk or {}, {
		name = Version.SDK_NAME,
		version = Version.SDK_VERSION
	})

	local options = Client.getOptions()
	local environment = options.environment
	local release = options.release
	local dist = options.dist
	local maxValueLength = options.maxValueLength or 250

	local prepared = Cryo.Dictionary.join(event, {})
	if prepared.environment == nil and environment ~= nil then
		prepared.environment = environment
	end
	if prepared.release == nil and release ~= nil then
		prepared.release = release
	end

	if prepared.dist == nil and dist ~= nil then
		prepared.dist = dist
	end

	if prepared.message then
		prepared.message = prepared.message:sub(1, maxValueLength)
	end

	if prepared.event_id == nil then
		prepared.event_id = generateUUID()
	end

	local result = prepared

	if scope then
		result = scope:applyToEvent(prepared, hint)
	end

	return result
end

return Client