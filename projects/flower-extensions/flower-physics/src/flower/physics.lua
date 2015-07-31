----------------------------------------------------------------------------------------------------
-- Physics Library.
-- TODO:There is only a prototype
-- @author Makoto
----------------------------------------------------------------------------------------------------

-- module
local M = {}

-- import
local flower = require "flower"
local class = flower.class
local table = flower.table
local PropertyUtils = flower.PropertyUtils
local ClassFactory = flower.ClassFactory
local Event = flower.Event
local DisplayObject = flower.DisplayObject
local Image = flower.Image
local MovieClip = flower.MovieClip

-- class
local B2World
local B2Body
local B2Fixture

-- variables
local MOAIBox2DWorldInterface = MOAIBox2DWorld.getInterfaceTable()
local MOAIBox2DBodyInterface = MOAIBox2DBody.getInterfaceTable()
local MOAIBox2DFixtureInterface = MOAIBox2DFixture.getInterfaceTable()

----------------------------------------------------------------------------------------------------
-- @type B2World
----------------------------------------------------------------------------------------------------
B2World = class()
B2World.__index = MOAIBox2DWorldInterface
B2World.__moai_class = MOAIBox2DWorld
M.B2World = B2World

--- Default Gravity
B2World.DEFAULT_GRAVITY = {0, 10}

--- Default UnitsToMeters
B2World.DEFAULT_UNITS_TO_METERS = 0.06

--- Constants representing the type of the Body.
B2World.BODY_TYPES = {
    dynamic = MOAIBox2DBody.DYNAMIC,
    static = MOAIBox2DBody.STATIC,
    kinematic = MOAIBox2DBody.KINEMATIC
}

--------------------------------------------------------------------------------
-- The constructor.
-- @param params
--------------------------------------------------------------------------------
function B2World:init()
    self.imageFactory = ClassFactory(Image)
    self.movieClipFactory = ClassFactory(MovieClip)
    self:setGravity(unpack(B2World.DEFAULT_GRAVITY))
    self:setUnitsToMeters(unpack(B2World.DEFAULT_UNITS_TO_METERS))
end


function B2World:createImage(params)
    assert(params.texture, "Not property found!->texture")
    return self:createBody {
        prop = Image(params.texture),
        bodyType = params.bodyType,
        fixtureData = params.fixtureData,
    }
end


function B2World:createMovieClip(params)
    assert(params.texture, "Not property found!->texture")
    return self:createBody {
        prop = MovieClip(params.texture),
        bodyType = params.bodyType,
        fixtureData = params.fixtureData,
    }
end


--------------------------------------------------------------------------------
-- Create a Body based on MOAIProp.
-- @param prop MOAIProp instance.
-- @param bodyType The type of the Body.
-- @param ... physicsDatas. Data that was created in PhysicsEditor can be used.
-- @return PhysicsBody instance.
--------------------------------------------------------------------------------
function B2World:createBody(params)
    local prop = assert(params.prop)
    local bodyType = assert(params.bodyType)
    local physicsData = params.physicsData or {}

    if #physicsData == 0 then
        table.insert(physicsData, {shape = "rectangle"})
    end

    local body = self:addBody(bodyType)
    local width, height = prop:getSize()
    local sx, sy = prop:getScl()

    width = width * math.abs(sx)
    height = height * math.abs(sy)

    local xMin, yMin, xMax, yMax = -width / 2, -height / 2, width / 2, height / 2

    for i, data in ipairs(physicsData) do
        data = table.copy(data)
        if data.shape == "rectangle" then
            data.xMin = data.xMin or xMin
            data.yMin = data.yMin or yMin
            data.xMax = data.xMax or xMax
            data.yMax = data.yMax or yMax
        elseif data.shape == "circle" then
            data.radius = data.radius or width / 2
            data.center = data.center or {x = 0, y = 0}
        end
        body:addFixtureData(data)
    end

    prop:setPos(xMin, yMin)
    prop:setBody(body)
    prop.body = body
    body.prop = prop

    body:resetMassData()
    return body
end

--------------------------------------------------------------------------------
-- Add the PhysicsBody object.
-- @param bodyType Can also be specified in the extended string.
-- @return PhysicsBody instance.
--------------------------------------------------------------------------------
function B2World:addBody(bodyType)
    bodyType = bodyType or "dynamic"
    bodyType = type(bodyType) == "string" and B2World.BODY_TYPES[bodyType] or bodyType
    return B2Body(MOAIBox2DWorldInterface.addBody(self, bodyType))
end

----------------------------------------------------------------------------------------------------
-- @type B2Body
----------------------------------------------------------------------------------------------------
B2Body = class()
B2Body.__index = MOAIBox2DBodyInterface
B2Body.__moai_class = MOAIBox2DBody
M.B2Body = B2Body


function B2Body:__new(body, ...)
    body:setInterface(self.__interface)
    body:init(...)
    return body
end

--------------------------------------------------------------------------------
-- The constructor.
--------------------------------------------------------------------------------
function B2Body:init()
    self._fixtures = {}
end

--------------------------------------------------------------------------------
-- Add the PhysicsData was created in PhysicsEditor.
-- Partially, it is proprietary.
-- @param ... fixture data
--------------------------------------------------------------------------------
function B2Body:addFixtureData(...)
    for i, data in ipairs({...}) do
        if data.radius then
            local fixture = self:addCircle(data.center.x, data.center.y, data.radius)
            fixture:setProperties(data)
        elseif data.shape == "rectangle" then
            local fixture = self:addRect(data.xMin, data.yMin, data.xMax, data.yMax)
            fixture:setProperties(data)
        elseif type(data.shape) == "table" then
            local fixture = self:addPolygon(data.shape)
            fixture:setProperties(data)
        end
    end
end

--------------------------------------------------------------------------------
-- Add a circle.
--------------------------------------------------------------------------------
function B2Body:addCircle(x, y, radius)
    local fixture = MOAIBox2DBodyInterface.addCircle(self, x, y, radius)
    fixture = B2Fixture(fixture)
    table.insert(self._fixtures, fixture)
    return fixture
end

--------------------------------------------------------------------------------
-- Add the edge.
--------------------------------------------------------------------------------
function B2Body:addEdges(verts)
    local fixture = MOAIBox2DBodyInterface.addEdges(self, verts)
    fixture = B2Fixture(fixture)
    fixture:setProperties(M.DEFAULT_FIXTURE_PARAMS)
    table.insert(self._fixtures, fixture)
    return fixture
end

--------------------------------------------------------------------------------
-- Adds a polygon.
--------------------------------------------------------------------------------
function B2Body:addPolygon(verts)
    local fixture = MOAIBox2DBodyInterface.addPolygon(self, verts)
    fixture = B2Fixture(fixture)
    table.insert(self._fixtures, fixture)
    return fixture
end

--------------------------------------------------------------------------------
-- Add a rectangle.
--------------------------------------------------------------------------------
function B2Body:addRect(xMin, yMin, xMax, yMax)
    local fixture = MOAIBox2DBodyInterface.addRect(self, xMin, yMin, xMax, yMax)
    fixture = B2Fixture(fixture)
    table.insert(self._fixtures, fixture)
    return fixture
end

--------------------------------------------------------------------------------
-- Returns the Fixture for all.
-- @return Fixtures
--------------------------------------------------------------------------------
function B2Body:getFixtures()
    return self._fixtures
end

--------------------------------------------------------------------------------
-- Sets the collision handler to fixtures.
-- @param handler collision handler
-- @param arbiter collision arbiter
--------------------------------------------------------------------------------
function B2Body:setCollisionHandlers(handler, arbiter)
    for i, fixture in ipairs(self._fixtures) do
        fixture:setCollisionHandler(handler, arbiter)
    end
end

--------------------------------------------------------------------------------
-- Sets angle.
-- @param angle angle
--------------------------------------------------------------------------------
function B2Body:setAngle(angle)
    local x, y = self:getPos()
    self:setTransform(x, y, angle)
end

--------------------------------------------------------------------------------
-- Sets the position.
-- @param x position x.
-- @param y position y.
--------------------------------------------------------------------------------
function B2Body:setPos(x, y)
    self:setTransform(x, y, self:getAngle())
end

--------------------------------------------------------------------------------
-- Returns the position.
-- @return x, y.
--------------------------------------------------------------------------------
function B2Body:getPos()
    return self:getPosition()
end

--------------------------------------------------------------------------------
-- Adds the position.
-- @param x x position
-- @param x y position
--------------------------------------------------------------------------------
function B2Body:addPos(x, y)
    local nowX, nowY = self:getPos()
    self:setPos(x + nowX, y + nowY)
end

----------------------------------------------------------------------------------------------------
-- @type B2Body
----------------------------------------------------------------------------------------------------
B2Fixture = class()
B2Fixture.__index = MOAIBox2DFixtureInterface
B2Fixture.__moai_class = MOAIBox2DFixture
M.B2Fixture = B2Fixture


function B2Fixture:__new(fixture, ...)
    fixture:setInterface(self.__interface)
    fixture:init(...)
    return fixture
end


--------------------------------------------------------------------------------
-- The constructor.
--------------------------------------------------------------------------------
function B2Fixture:init()
    --
end

--------------------------------------------------------------------------------
-- Set the parameter setter function.
-- @param params Parameter is set to Object.
-- (params:density, friction, restitution, filter, collisionHandler, collisionArbiter)
--------------------------------------------------------------------------------
function B2Fixture:setProperties(params)
    self.name = self.name or params.pe_fixture_id or params.name
    self.preserve = self.preserve or params.preserve
    if params.density then
        self:setDensity(params.density)
    end
    if params.friction then
        self:setFriction(params.friction)
    end
    if params.restitution then
        self:setRestitution(params.restitution)
    end
    if params.sensor then
        self:setSensor(params.sensor)
    end
    if params.filter then
        local filter = params.filter
        self:setFilter(filter.categoryBits, filter.maskBits, filter.groupIndex)
    end
    if params.collisionHandler then
        local collisionHandler = params.collisionHandler
        local collisionArbiter = params.arbiter or MOAIBox2DArbiter.ALL
        self:setCollisionHandler(collisionHandler, collisionArbiter)
    end
end

--------------------------------------------------------------------------------
-- Destroys the Fixture.
--------------------------------------------------------------------------------
function B2Fixture:destroy()
    local body = self:getBody()
    MOAIBox2DFixtureInterface.destroy(self)

    local fixtures = body:getFixtures()
    table.removeElement(fixtures, self)
end

return M
