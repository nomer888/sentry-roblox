##Sentry

---

###init
```
Sentry.init(options: Dictionary) -> nil
```

Initializes the SDK with the provided options. Call this method before using any others.

!!! note
	If `options.dsn` is nil or an empty string, the SDK is disabled.

---

###captureMessage
```
Sentry.captureMessage(message: string, [level: SeverityLevel]) -> string
```
Sends `message` to Sentry. Returns the event id that will correspond to the event on the site.

`level` defaults to Sentry.Level.Error

---

###captureException
```
Sentry.captureException(exception: string) -> string
```
Sends `exception` to Sentry. Returns the event id that will correspond to the event on the site.

Use `debug.traceback(message)` to send a stack trace.

---

###captureEvent
```
Sentry.captureEvent(event: Event) -> string
```
Sends `event` to Sentry. Returns the event id that will correspond to the event on the site.

`event` must follow the [Event payload specification](https://docs.sentry.io/development/sdk-dev/event-payloads/).

---

###addBreadcrumb

TODO

---

###configureScope

TODO

---

###withScope

TODO

---

###getLastEventId
```
Sentry.getLastEventId() -> string
```
Returns the last event id sent by the SDK. Typically used for user feedback.
