local Cryo = require(script.Parent.Cryo)
local Promise = require(script.Parent.Promise)

local Scope = {}
Scope.__index = Scope

function Scope.new()
	local self = {}

	self._notifyingListeners = false
	self._scopeListeners = {}
	self._eventProcessors = {}
	self._breadcrumbs = {}
	self._user = {}
	self._tags = {}
	self._extra = {}
	self._context = {}
	self._fingerprint = {}
	self._level = nil
	self._transaction = nil
	self._span = nil

	setmetatable(self, Scope)
	return self
end

function Scope.clone(scope)
	local newScope = Scope.new()
	if scope then
		scope._scopeListeners = {}
		newScope._breadcrumbs = Cryo.List.join(scope._breadcrumbs, {})
		newScope._tags = Cryo.Dictionary.join(scope._tags, {})
		newScope._extra = Cryo.Dictionary.join(scope._extra, {})
		newScope._context = Cryo.Dictionary.join(scope._context, {})
		newScope._user = scope._user
		newScope._level = scope._level
		newScope._span = scope._span
		newScope._transaction = scope._transaction
		newScope._fingerprint = scope._fingerprint
		newScope._eventProcessors = Cryo.List.join(scope._eventProcessors, {})
	end
	return newScope
end

function Scope:addScopeListener(callback)
	self._scopeListeners[#self._scopeListeners + 1] = callback
end

function Scope:addEventListener(callback)
	self._eventListeners[#self._eventListeners + 1] = callback
	return self
end

function Scope:_notifyScopeListeners()
	if not self._notifyingListeners then
		self._notifyingListeners = true
		coroutine.wrap(function()
			Cryo.List.forEach(function(callback)
				callback(self)
			end)
			self._notifyingListeners = false
		end)()
	end
end

function Scope:_notifyEventProcessors(processors, event, hint)
	return Promise.new(function(resolve, reject)
		local nextEvent = Cryo.Dictionary.join(event, {})
		for _, processor in ipairs(processors) do
			local success, _nextEvent = pcall(processor, nextEvent, hint)
			if success then
				nextEvent = _nextEvent
			else
				reject(_nextEvent)
			end
		end
		resolve(nextEvent)
	end)
end

function Scope:setUser(user)
	self._user = Cryo.Dictionary.join(user, {})
	self:_notifyScopeListeners()
	return self
end

function Scope:setTags(tags)
	self._tags = Cryo.Dictionary.join(self._tags, tags)
	self:_notifyScopeListeners()
	return self
end

function Scope:setTag(key, value)
	self._tags = Cryo.Dictionary.join(self._tags, {[key] = value})
	self:_notifyScopeListeners()
	return self
end

function Scope:setExtras(extra)
	self._extra = Cryo.Dictionary.join(self._extra, extra)
	self:_notifyScopeListeners()
	return self
end

function Scope:setExtra(key, extra)
	self.extra = Cryo.Dictionary.join(self._extra, {[key] = extra})
	self:_notifyScopeListeners()
	return self
end

function Scope:setFingerprint(fingerprint)
	self._fingerprint = Cryo.Dictionary.join(fingerprint, {})
	self:_notifyScopeListeners()
	return self
end

function Scope:setLevel(level)
	self._level = level
	self:_notifyScopeListeners()
	return self
end

function Scope:setTransaction(transaction)
	self._transaction = transaction
	self:_notifyScopeListeners()
	return self
end

function Scope:setContext(name, context)
	self._context[name] = Cryo.Dictionary.join(context, {})
	self:_notifyScopeListeners()
	return self
end

function Scope:clear()
	self._breadcrumbs = {}
	self._tags = {}
	self._extra = {}
	self._user = {}
	self._context = {}
	self._level = nil
	self._transaction = nil
	self._fingerprint = {}
	self._span = nil
	self:_notifyScopeListeners()
end

function Scope:addBreadcrumb(breadcrumb, maxBreadcrumbs)
	local timestamp = os.time()
	local mergedBreadcrumb = Cryo.Dictionary.join(breadcrumb, {timestamp = timestamp})
	local breadcrumbs = Cryo.List.join(self._breadcrumbs, mergedBreadcrumb)
	if maxBreadcrumbs ~= nil and maxBreadcrumbs >= 0 and #breadcrumbs > maxBreadcrumbs then
		breadcrumbs = Cryo.List.removeRange(breadcrumbs, maxBreadcrumbs, #breadcrumbs)
	end
	self._breadcrumbs = breadcrumbs
	self:_notifyScopeListeners()
	return self
end

function Scope:clearBreadcrumbs()
	self._breadcrumbs = {}
	self:_notifyScopeListeners()
	return self
end

function Scope:applyFingerprint(event)
	if not event.fingerprint then
		event.fingerprint = {}
	else
		if type(event.fingerprint) ~= "table" then
			event.fingerprint = {event.fingerprint}
		end
	end

	if self._fingerprint then
		event.fingerprint = Cryo.List.join(event.fingerprint, self._fingerprint)
	end

	if event.fingerprint and #event.fingerprint == 0 then
		event.fingerprint = nil
	end
end

function Scope:applyToEvent(event, hint)
	if next(self._extra) ~= nil then
		event.extra = Cryo.Dictionary.join(self._extra, event.extra or {})
	end
	if next(self._tags) ~= nil then
		event.tags = Cryo.Dictionary.join(self._tags, event.tags or {})
	end
	if next(self._user) ~= nil then
		event.user = Cryo.Dictionary.join(self._user, event.user or {})
	end
	if next(self._context) ~= nil then
		event.context = Cryo.Dictionary.join(self._context, event.context or {})
	end
	if self._level then
		event.level = self._level
	end
	if self._transaction then
		event.transaction = self._transaction
	end

	self:applyFingerprint(event)

	event.breadcrumbs = Cryo.List.join(event.breadcrumbs or {}, self._breadcrumbs)
	if #event.breadcrumbs == 0 then
		event.breadcrumbs = nil
	end

	return event
end

return Scope