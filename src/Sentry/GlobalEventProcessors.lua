local globalEventProcessors = {}

local function getGlobalEventProcessors()
	return globalEventProcessors
end

local function addGlobalEventProcessor(callback)
	globalEventProcessors[#globalEventProcessors + 1] = callback
end

return {
	getGlobalEventProcessors = getGlobalEventProcessors,
	addGlobalEventProcessor = addGlobalEventProcessor
}