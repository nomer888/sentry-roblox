-- https://docs.sentry.io/development/sdk-dev/unified-api/#client
local generateUUID = require(script.Parent.generateUUID)
local Transport = require(script.Parent.Transport)
local Version = require(script.Parent.Version)

local Client = {}
Client.__index = Client

function Client.new(options)
	local self = {}
	self._options = options
	setmetatable(self, Client)
	return self
end

function Client:getOptions()
	return self._options
end

function Client:_prepareEvent(event, scope)
	local options = self:getOptions()
	local prepared = event
	prepared.platform = prepared.platform or "other"
	prepared.sdk = {
		name = Version.SDK_NAME,
		version = Version.SDK_VERSION
	}
	if not prepared.environment then
		prepared.environment = options.environment
	end
	if not prepared.release then
		prepared.release = options.release
	end
	if not prepared.dist then
		prepared.dist = options.dist
	end
	if not prepared.message then
		prepared.message = options.message
	end
	if not prepared.event_id then
		prepared.event_id = generateUUID()
	end
	if scope then
		prepared = scope:applyToEvent(prepared)
	end
	return prepared
end

function Client:_processEvent(event)
	local options = self:getOptions()
	if math.random() < options.sampleRate then
		return
	end
	local prepared = self:_prepareEvent(event)
	local beforeSendResult = prepared
	if options.beforeSend then
		beforeSendResult = options.beforeSend(prepared)
	end
	if not beforeSendResult then
		return
	end
	Transport.sendEvent(beforeSendResult, options.dsn)
end

function Client:captureEvent(event, scope)
end

function Client:close(timeout)
end

function Client:flush(timeout)
end

return Client