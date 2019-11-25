local HttpService = game:GetService("HttpService")

local Parse = require(script.Parent.Parse)
local Version = require(script.Parent.Version)

local Transport = {}
Transport.__index = Transport

function Transport.new(dsn)
	local self = {}
	self._dsn = Parse.dsn(dsn)
	self._queue = {}
	self._closed = false
	setmetatable(self, Transport)
	while not self._closed do
		for _, callback in ipairs(self._queue) do
			pcall(callback)
		end
		self._queue = {}
		wait(1)
	end
	return self
end

function Transport:_addToQueue(callback)
	self._queue[self._queue + 1] = callback
end

function Transport:sendEvent(event)
	if self._closed then
		return
	end
	local dsn = self._dsn
	local baseUri = ("%s://%s"):format(dsn.protocol, dsn.host)
	local url = ("%s/api/%d/store/"):format(baseUri, dsn.projectId)
	local agent = ("%s/%s"):format(Version.SDK_NAME, Version.SDK_VERSION)
	local auth = {
		sentry_version = Version.PROTOCOL_VERSION,
		sentry_client = agent,
		sentry_timestamp = os.time(),
		sentry_key = dsn.publicKey,
		sentry_secret = dsn.secretKey
	}
	local request = {
		Url = url,
		Method = "POST",
		Headers = {
			["User-Agent"] = agent,
			["Content-Type"] = "application/json",
			["X-Sentry-Auth"] = auth
		},
		Body = HttpService:JSONEncode(event)
	}
	self:_addToQueue(function()
		if self._retryAfter then
			wait(self._retryAfter - os.time())
			self._retryAfter = nil
		end
		local ok, result = pcall(function()
			HttpService:RequestAsync(request)
		end)
		if not ok then
			return
		end
		if not result.Success then
			local message = ("HTTP Error %d: %s\n"):format(result.StatusCode, result.StatusMessage)
			if result.Headers["x-sentry-error"] then
				message = message .. result.Headers["x-sentry-error"]
			end
			warn(message)
			if result.StatusCode == 429 then
				local retryAfter = result.Headers["Retry-After"]
				if retryAfter then
					wait(retryAfter)
				end
			end
		end
	end)
end

function Transport:close(timeout)
end

return Transport