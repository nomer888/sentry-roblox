local Dsn = require(script.Parent.Dsn)

local SENTRY_API_VERSION = "7"

local API = {}
API.__index = API

function API.new()
	local self = {}
	self._dsnObject = Dsn
	setmetatable(self, API)
	return self
end

function API:getDsn()
	return self._dsnObject
end

function API:getStoreEndpoint()
	return ("%s%s"):format(self:_getBaseUrl(), self:getStoreEndpointPath())
end

function API:_getBaseUrl()
	local dsn = self._dsnObject
	local protocol = dsn.protocol and dsn.protocol..":" or ""
	local port = dsn.port and dsn.port ~= "" and ":"..dsn.port or ""
	return ("%s//%s%s"):format(protocol, dsn.host, port)
end

function API:getStoreEndpointPath()
	local dsn = self._dsnObject
	return ("%s/api/%s/store/"):format(dsn.path and "/"..dsn.path or "", dsn.projectId)
end

function API:getRequestHeaders(clientName, clientVersion)
	local dsn = self._dsnObject
	print(dsn.publicKey)
	local header = {("Sentry sentry_version=%s"):format(SENTRY_API_VERSION),
		("sentry_timestamp=%s"):format(tostring(os.time())),
		("sentry_client=%s/%s"):format(tostring(clientName), tostring(clientVersion)),
		("sentry_key=%s"):format(dsn.publicKey),
		dsn.pass and ("sentry_secret=%s"):format(dsn.secretKey)
	}
	return {
		["Content-Type"] = "application/json",
		["X-Sentry-Auth"] = table.concat(header, ", ")
	}
end

return API