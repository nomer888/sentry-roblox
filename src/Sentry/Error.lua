local ErrorType = require(script.Parent.ErrorType)

local Error = {}
Error.__index = Error

function Error.new(message, errorType, trace)
	local self = {}
	self.message = message
	self.errorType = errorType or ErrorType.Error
	self.traceback = trace or debug.traceback(2)
	setmetatable(self, Error)
	return self
end

return Error