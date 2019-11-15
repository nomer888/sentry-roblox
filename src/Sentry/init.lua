local Hub = require(script.Hub)
local Client = require(script.Client)
local Level = require(script.Level)

local Sentry = {
	Level = Level
}

function Sentry.init(options)
	Sentry._options = options
	Client.init(options)
	Hub.bindClient(Client)
end

function Sentry.captureEvent(event)
	return Hub.captureEvent(event)
end

function Sentry.captureException(error)
	return Hub.captureException(error)
end

function Sentry.captureMessage(message, level)
	return Hub.captureMessage(message, level)
end

function Sentry.addBreadcrumb(crumb)

end

function Sentry.configureScope(callback)

end

return Sentry