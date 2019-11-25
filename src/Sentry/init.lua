-- https://docs.sentry.io/development/sdk-dev/unified-api/#static-api
local Hub = require(script.Hub)
local Client = require(script.Client)
-- local Types = require(script.Types)
local DefaultIntegrations = require(script.DefaultIntegrations)

local globalOptions
local disabled = true

local function getDefaultOptions()
	return {
		sampleRate = 1,
		maxBreadcrumbs = 100,
		attachStacktrace = false,
		defaultIntegrations = true,
		shutdownTimeout = 2
	}
end

local Sentry = {}

Sentry.Level = {
	Fatal = "fatal",
	Error = "error",
	Warning = "warning",
	Info = "info",
	Debug = "debug"
}

function Sentry.init(options)
	local default = getDefaultOptions()
	for i, v in pairs(options) do
		default[i] = v
	end
	-- assert(Types.options(default))
	globalOptions = default
	Hub.setCurrent(Hub.new(Client.new(globalOptions)))
	disabled = globalOptions.dsn == nil or globalOptions.dsn == ""
	if not disabled then
		for name, integration in pairs(DefaultIntegrations) do
			integration(Sentry)
			print("Integration installed:", name)
		end
	end
end

function Sentry.captureEvent(event)
	if not disabled then
		return Hub.getCurrent():captureEvent(event)
	end
end

function Sentry.captureException(exception)
	if not disabled then
		local hint = {
			sourceTrace = debug.traceback("Sentry syntheticException", 2)
		}
		return Hub.getCurrent():captureException(exception, hint)
	end
end

function Sentry.captureMessage(message, level)
	if not disabled then
		local hint = {
			sourceTrace = debug.traceback("Sentry syntheticException", 2)
		}
		return Hub.getCurrent():captureMessage(message, level, hint)
	end
end

function Sentry.addBreadcrumb(crumb)
	if not disabled then
	end
end

function Sentry.configureScope(callback)
	if not disabled then
	end
end

function Sentry.getLastEventId()
	if not disabled then
	end
end

return Sentry