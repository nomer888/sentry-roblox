local Backend = {}
Backend.__index = Backend

function Backend.new(options)
	local self = {}
	self._options = options
	if not options.dsn then
		warn("No DSN provided, backend will not do anything")
	end
	self._transport = Backend._setupTransport(self)
end

function Backend:eventFromMessage(message, level, hint)
	local event = {
		event_id = hint and hint.event_id,
		level = level,
		message = message
	}

	if self._options.attachStacktrace and hint and hint.syntheticException then

	end
	return event
end

return Backend