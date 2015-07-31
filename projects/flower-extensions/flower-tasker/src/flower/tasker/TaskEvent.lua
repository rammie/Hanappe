----------------------------------------------------------------------------------------------------
-- TODO:LuaDoc
----------------------------------------------------------------------------------------------------

-- import
local class = require "flower.class"
local Event = require "flower.Event"

-- class
local TaskEvent = class(Event)

--- taskStart
TaskEvent.TASK_START = "taskStart"

--- taskEnd
TaskEvent.TASK_END = "taskEnd"

--- taskCancel
TaskEvent.TASK_CANCEL = "taskCancel"

--- taskAbort
TaskEvent.TASK_ABORT = "taskAbort"

return TaskEvent