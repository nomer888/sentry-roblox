local Types = {}

-- https://docs.sentry.io/error-reporting/configuration/
Types.options = t.strictInterface({
	dsn = t.optional(t.string),
	debug = t.optional(t.bool),
	release = t.optional(t.string),
	environment = t.optional(t.string),
	sampleRate = t.number,
	maxBreadcrumbs = t.number,
	attachStacktrace = t.bool,
	defaultIntegrations = t.bool,
	beforeSend = t.optional(t.callback),
	beforeBreadcrumb = t.optional(t.callback),
	shutdownTimeout = t.number
})

-- https://docs.sentry.io/development/sdk-dev/event-payloads/
Types.event = t.interface({
	-- required
	event_id = t.string,
	timestamp = t.union(t.string, t.number),
	logger = t.string,
	platform = t.string,
	-- optional
	level = t.optional(t.string),
	transaction = t.optional(t.string),
	server_name = t.optional(t.string),
	release = t.optional(t.string),
	dist = t.optional(t.string),
	tags = t.optional(t.map(t.string, t.any)),
	environment = t.optional(t.string),
	modules = t.optional(t.map(t.string, t.any)),
	extra = t.optional(t.map(t.string, t.any)),
	fingerprint = t.optional(t.array(t.string)),

})

return Types