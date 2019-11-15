local HttpService = game:GetService("HttpService")

local API = require(script.Parent.API)
local Cryo = require(script.Parent.Cryo)
local Version = require(script.Parent.Version)
local TaskQueue = require(script.Parent.TaskQueue)

local Transport = {}
Transport.__index = Transport

function Transport.new(options)
	local self = {}
	self._api = API.new(options.dsn)
	self._options = options
	self._taskQueue = TaskQueue.new(30)
	setmetatable(self, Transport)
	return self
end

function Transport:_getRequestOptions()
	local headers = Cryo.Dictionary.join(
		self._api:getRequestHeaders(Version.SDK_NAME, Version.SDK_VERSION),
		self._options.headers or {}
	)
	local dsn = self._api:getDsn()

	print(self._api:getStoreEndpoint())
	return {
		Url = self._api:getStoreEndpoint(),
		Method = "POST",
		Headers = headers,
	}
end

function Transport:_sendEvent(event)
	self._taskQueue:add(function()
		local request = self:_getRequestOptions()
		local encodeSuccess, encodeResult = pcall(function()
			return HttpService:JSONEncode(event)
		end)
		if not encodeSuccess then
			print(encodeResult)
			return
		end
		request.Body = encodeResult
		local success, response = pcall(function()
			return HttpService:RequestAsync(request)
		end)
		if not success then
			print(response)
			return
		end
		if response.Success then
			print("succeeded")
		else
			if response.Headers and response.Headers["x-sentry-error"] then
				print("error", response.Headers["x-sentry-error"])
			else
				print("error")
			end
		end
	end)
end

function Transport:flush(timeout)
	return self._taskQueue:flush(timeout)
end

return Transport