-- import
local position = require "position"
flower = require "flower"
tiled = require "tiled"
widget = require "widget"
Resources = flower.Resources

-- Resources setting
Resources.addResourceDirectory("assets")

-- debug
--[[
MOAIDebugLines.setStyle ( MOAIDebugLines.TEXT_BOX, 1, 1, 1, 1, 1 )
MOAIDebugLines.setStyle ( MOAIDebugLines.TEXT_BOX_LAYOUT, 1, 0, 0, 1, 1 )
MOAIDebugLines.setStyle ( MOAIDebugLines.TEXT_BOX_BASELINES, 1, 1, 0, 0, 1 )
MOAIDebugLines.setStyle ( MOAIDebugLines.PROP_MODEL_BOUNDS, 2, 1, 1, 1 )
MOAIDebugLines.setStyle ( MOAIDebugLines.PROP_WORLD_BOUNDS, 2, 0.75, 0.75, 0.75 )
]]

-- Screen setting
local screenWidth = 320--MOAIEnvironment.horizontalResolution or 320
local screenHeight = 480--MOAIEnvironment.verticalResolution or 480
local screenDpi = MOAIEnvironment.screenDpi or 120
local viewScale = math.floor(screenDpi / 240) + 1
print(screenWidth, screenHeight)
-- open window

position.init(screenWidth, screenHeight)

flower.openWindow("Flower extensions", screenWidth, screenHeight)--, viewScale)

-- open scene
flower.openScene("main_scene")