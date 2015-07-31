module(..., package.seeall)

local UIView = widget.UIView
local UIGroup = widget.UIGroup
local Button = widget.Button
local BoxLayout = widget.BoxLayout

--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------

function onCreate(e)
    view = widget.UIView {
        scene = scene,
        layout = BoxLayout {
            gap = {5, 5},
        },
    }
    
    button1 = widget.Button {
        size = {200, 50},
        text = "Task1",
        parent = view,
        onClick = function(e)
            print("onClick")
            task1:execute()
        end,
    }

    button2 = widget.Button {
        size = {200, 50},
        text = "Task2",
        parent = view,
        onClick = function(e)
            print("onClick")
            task2:execute()
        end,
    }

    task1 = tasker.Task {
        commands = {{
            tasker.EchoCommand {
                message = "はろー1"
            },
            tasker.EchoCommand {
                message = "はろー2"
            },
        }},
        onTaskStart = function(e)
            print("onTaskStart")
        end,
        onTaskEnd = function(e)
            print("onTaskEnd")
        end,
        onTaskCancel = function(e)
            print("onTaskCancel")
        end,
        onTaskAbort = function(e)
            print("onTaskAbort")
        end,
    }

    task2 = tasker.Task {
        commands = {{
            tasker.EchoCommand {
                message = "はろー3"
            },
            tasker.EchoCommand {
                message = "ここにはこないよ",
                executeWhen = false,
            },
            tasker.EchoCommand {
                message = "ここにもこないよ",
                executeWhen = function(context)
                    return false
                end,
            },
            tasker.EchoCommand {
                message = "ここにはくるよ",
                executeWhen = function(context)
                    return context.status == 0
                end,
            },
            tasker.SetContextCommand {
                params = {{message = "はろーはろー"}},
            },
            tasker.FunctionCommand {
                callback = function(context)
                    print(context:getParam("message"))
                end,
            },
            tasker.AbortCommand {},
            tasker.EchoCommand {
                message = "ここにはこないよ",
            },
        }},
        aborts = {{
            tasker.EchoCommand {
                message = "エラーになった"
            },
        }},
        onTaskStart = function(e)
            print("onTaskStart")
        end,
        onTaskEnd = function(e)
            print("onTaskEnd")
        end,
        onTaskCancel = function(e)
            print("onTaskCancel")
        end,
        onTaskAbort = function(e)
            print("onTaskAbort")
        end,
    }

end
