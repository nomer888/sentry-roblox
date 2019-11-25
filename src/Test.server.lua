local Sentry = require(script.Parent.Sentry)

Sentry.init({
	dsn = "",
	attachStacktrace = true,
	release = "1.0.1",
	environment = "dev"
})

Sentry.captureMessage("hello", Sentry.Level.Info)

local function x()
	return debug.traceback("hello")
end

local function y()
	return x()
end

Sentry.captureException("test adding synthetic stacktrace")
Sentry.captureEvent({
	level = "warning",
	message = {
		message = "test"
	}
})

-- Sentry.captureException(y())

local ScriptContext = game:GetService("ScriptContext")

ScriptContext.Error:Connect(function(message, trace)
	local full = ("%s\nStack Begin\n%sStack End"):format(message, trace)
	-- Sentry.captureException(full)
	print(full)
end)

pcall(function()
	wait()
	x()
	error("error from yielding pcall")
end)