local pattern = "^(%w+)%:%/%/(%w+)%:?(%w*)%@([%w%.%-]+)%:?(%d*)%/(%d+)"

local Dsn = {}

function Dsn.fromString(str)
	local protocol, publicKey, secretKey, host, port, projectId = str:match(pattern)
	Dsn.protocol = protocol
	print(protocol)
	Dsn.publicKey = publicKey
	print(publicKey)
	Dsn.secretKey = secretKey or ""
	print(secretKey)
	Dsn.host = host
	print(host)
	Dsn.port = port
	print(port)
	Dsn.projectId = projectId
	print(projectId)
end

return Dsn