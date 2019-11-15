local RunService = game:GetService("RunService")

local TaskQueue = {}
TaskQueue.__index = TaskQueue

function TaskQueue.new(maxQueueSize)
	local self = {}
	self._maxQueueSize = maxQueueSize
	self._buffer = {}
	self._thread = coroutine.wrap(function()
		while true do
			while #self._buffer > 0 do
				print'processing'
				local index = #self._buffer
				self._buffer[index]()
				table.remove(self._buffer, index)
			end
			wait(1)
		end
	end)()
	setmetatable(self, TaskQueue)
	return self
end

function TaskQueue:add(callback)
	if #self._buffer < self._maxQueueSize then
		self._buffer[#self._buffer + 1] = callback
		print'added'
	end
end

function TaskQueue:flush(timeout)
	local start = tick()
	while tick() - start <= timeout and self._isRunning do
		RunService.Heartbeat:Wait()
	end
	return self._isRunning == false
end

return TaskQueue