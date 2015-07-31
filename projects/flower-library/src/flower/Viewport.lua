----------------------------------------------------------------------------------------------------
-- The Viewport class.
--
-- <h4>Extends:</h4>
-- <ul>
--   <li><a href="flower.EventDispatcher.html">EventDispatcher</a><l/i>
--   <li><a href="http://moaiforge.github.io/moai-sdk/api/latest/class_m_o_a_i_viewport.html">MOAIViewport</a><l/i>
-- </ul>
--
-- @author Makoto
-- @release V3.0.0
----------------------------------------------------------------------------------------------------

-- import
local class = require "flower.class"
local Config = require "flower.Config"
local Window = require "flower.Window"
local Event = require "flower.Event"
local EventDispatcher = require "flower.EventDispatcher"

-- class
local Viewport = class(EventDispatcher)
Viewport.__index = MOAIViewport.getInterfaceTable()
Viewport.__moai_class = MOAIViewport

-- static variables
local DEFAULT_VIEWPORT = nil

---
-- Returns the defalut viewport.
-- @return Default viewport instance
function Viewport.getDefaultViewport()
    if not DEFAULT_VIEWPORT then
        DEFAULT_VIEWPORT = Viewport()
        DEFAULT_VIEWPORT:setAutoResizeEnabled(true)
    end
    return DEFAULT_VIEWPORT
end

---
-- Constructor.
function Viewport:init()
    Viewport.__super.init(self)

    self:updateViewSize(Config.WINDOW_WIDTH, Config.WINDOW_HEIGHT, Config.VIEWPORT_SCALE, Config.VIEWPORT_YFLIP)
    self:setAutoResizeEnabled(true)
end

---
-- Sets the auto resize when resize window.
-- @param value Auto resize enabled.
function Viewport:setAutoResizeEnabled(value)
    if self.autoResizeEnabled == value then
        return
    end

    if self.autoResizeEnabled then
        Window:removeEventListener(Event.RESIZE, self.onWindowResize, self)
    end

    self.autoResizeEnabled = value

    if self.autoResizeEnabled then
        Window:addEventListener(Event.RESIZE, self.onWindowResize, self)
    end
end

---
-- Updates the size and scale and offset.
-- @param width Width of the viewport.
-- @param height Height of the viewport.
-- @param viewScale Scale factor.
-- @param yFlip Y flip.
function Viewport:updateViewSize(width, height, viewScale, yFlip)
    self.width = width or self.width
    self.height = height or self.height

    self.viewScale = viewScale or self.viewScale
    self.viewWidth = self.width / self.viewScale
    self.viewHeight = self.height / self.viewScale
    self.yFlip = yFlip or self.yFlip

    self:setSize(self.width, self.height)

    if self.yFlip then
        self:setScale(self.viewWidth, self.viewHeight)
        self:setOffset(-1, -1)
    else
        self:setScale(self.viewWidth, -self.viewHeight)
        self:setOffset(-1, 1)
    end

    local e = Event(Event.RESIZE)
    e.width = self.width
    e.height = self.height
    e.viewWidth = self.viewWidth
    e.viewHeight = self.viewHeight
    e.viewScale = self.viewScale
    
    self:dispatchEvent(e)
end

function Viewport:onWindowResize(e)
    self:updateViewSize(e.width, e.height)
end

return Viewport
