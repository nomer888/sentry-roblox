return function(sdk)
	local ScriptContext = game:GetService("ScriptContext")
	local base = script.Parent:GetFullName()
	ScriptContext.Error:Connect(function(message, trace, originScript)
		if originScript:GetFullName():find(base, 1, true) then
			warn("SDK error: "..message.."\n"..trace)
			return
		end
		sdk:captureException(message.."\n"..trace)
	end)
end