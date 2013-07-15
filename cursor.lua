require "controls"  -- wand

--[[
    class Cursor
        Only one instance of Cursor is allowed; Cursor is automatically instantiated when this file is "require"d
        This instance is always accessible as the global variable cursor
        
        Vec3f :getPosition()
        Matrixd :getWandMatrix()   -- returns the current wand.matrix adjusted for the set cursor sensitivity
        void :changeAppearance(node)   -- pass any node (i.e. Transform, Geode) and it will be rendered as the new cursor image
        
        .sensitivity  -- Vec3d, the sensitivity factor (along each axis). Higher numbers make smaller wand movements move the cursor farther on-screen. Negative numbers will invert the wand, so don't use them.
        .defaultAppearance   -- a node to pass to :changeAppearance that contains the default appearance parameters
        -- alternate appearances to be added in the future
]]--

local CURSOR_SENSITIVITY = 2   -- the value to initialize cursor.sensitivity to

cursor = {}

local xform = osg.MatrixTransform(wand.matrix)

cursor.sensitivity = Vec(CURSOR_SENSITIVITY, CURSOR_SENSITIVITY, CURSOR_SENSITIVITY)

cursor.changeAppearance = function(cursor, geode)
    xform:removeChildren(0, xform:getNumChildren())
    xform:addChild(geode)
end

-- initialize cursor.defaultAppearance
local shapeDrawable = osg.ShapeDrawable(osg.Cone(Vecf(0,0,0), 0.15, 0.4))   -- tip is at (0, 0, 0.3)
shapeDrawable:setColor(Vecf(1.0, 1.0, 1.0, 1.0))
local geode = osg.Geode()
geode:addDrawable(shapeDrawable)
local permxform = Transform{ position = {0, -0.3, 0}, orientation = AngleAxis(Degrees(-90), Axis{1.0,0.0,0.0}) }   -- position component adjusts so that the cursor behaves as if the tip is its center
permxform:addChild(geode)
cursor.defaultAppearance = permxform

cursor.getPosition = function()
    return Vecf(geode:getWorldMatrices(RelativeTo.World).Item[1]:preMult(Vec(0,0,0)))
end

cursor.getWandMatrix = function()
    local wandMatrix = wand.matrix
    wandMatrix:postMult(osg.Matrixd.scale(cursor.sensitivity))
    return wandMatrix
end

function enableCursor()
    cursor:changeAppearance(cursor.defaultAppearance)
    World:addChild(xform)
    Actions.addFrameAction(function()
        local wandMatrix
        while true do
            xform:setMatrix(cursor:getWandMatrix())
            Actions.waitForRedraw()
        end
    end)
end
