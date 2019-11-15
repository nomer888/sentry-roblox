local Parsers = {}

function Parsers.extractStackFromTrace(str)
	if not str:match("Stack Begin.-Stack End$") then
		return
	end
	local stack = {}
	for _, line in ipairs(str:split("\n")) do
		local fileName, lineNo, varName = line:match("^Script '(.-)', Line (%d+)%s?%-?%s?(.*)$")
		if not fileName or not lineNo then
			fileName, lineNo, varName = line:match("^(.-), line (%d+)%s?%-?%s?(.*)$")
		end
		if fileName and lineNo then
			local frame = {
				filename = fileName,
				["function"] = varName,
				raw_function = varName,
				lineno = tonumber(lineNo)
			}
			table.insert(stack, 1, frame)
		end
	end
	return stack
end

function Parsers.extractMessageFromTrace(str)
	if not str:match("Stack Begin.-Stack End$") then
		return str
	end
	return str:match("^(.*)Stack Begin.-Stack End$")
end

return Parsers