##Installation

###Rojo

1. Copy [the src folder](https://gitlab.com/nomer/sentry-roblox/) into your repository
2. Rename the folder to Sentry

!!! note
	Sentry is intended to be used on the server

##Initialization

Once you have installed Sentry on the server, require and initialize it before using it anywhere else:
```lua
local ServerScriptService = game:GetService("ServerScriptService")

local Sentry = require(ServerScriptService.Sentry)

Sentry.init({
	dsn = ""
})
```

!!! danger
	***Do not share your DSN with anyone! Only require and initialize this module from the server.***

	If anyone else has access to your DSN, they can spam requests with it and put your Sentry account at risk.

You can view more options to use to configure Sentry here: [Configuration]()

##Capturing Messages

Sentry can be used to capture messages:

```lua
Sentry.captureMessage("Message from Roblox", Sentry.Level.Info)
```

You can use any valid severity level:

```
Fatal
Error
Warning
Info
Debug
```

##Capturing Errors

Sentry can be used to capture errors:

```lua
Sentry.captureException("Error from Roblox")
```

You can instead pass debug.traceback(message) to send a full stack trace to Sentry to find out *where* the error came from.

```lua
Sentry.captureException(debug.traceback("Error from Roblox"))
```
