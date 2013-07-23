require "controls"  -- wand

--[[
    class Cursor
        Only one instance of Cursor is allowed; Cursor is automatically instantiated when this file is "require"d
        This instance is always accessible as the global variable cursor
        
        Vec3f :getPosition()
        Matrixd :getWandMatrix()   -- returns the current wand.matrix adjusted for the set cursor sensitivity
        void :changeAppearance(node)   -- pass any node (i.e. Transform, Geode) and it (with all its children, of course) will be rendered as the new cursor image
        
        .defaultAppearance   -- a node to pass to :changeAppearance to restore the default appearance
        -- alternate appearances to be added in the future

        Private members:
        .xform - the osg.MatrixTransform used for tracking
]]--

local CURSOR_SENSITIVITY = 3   -- Higher numbers make smaller wand movements move the cursor farther on-screen. Negative numbers will invert the wand, so don't use them.

cursor = {}

cursor.xform = osg.MatrixTransform(wand.matrix)

cursor.changeAppearance = function(cursor, geode)
    cursor.xform:removeChildren(0, cursor.xform:getNumChildren())
    cursor.xform:addChild(geode)
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
    return Vecf(cursor.xform:getChild(0):getWorldMatrices(RelativeTo.World).Item[1]:preMult(Vec(0,0,0)))
end

cursor.getWandMatrix = function()
    local wandMatrix = wand.matrix
    wandMatrix:setTrans(CURSOR_SENSITIVITY*wandMatrix:getTrans())
    return wandMatrix
end

function enableCursor()
    cursor:changeAppearance(cursor.defaultAppearance)
	master_xform = Transform{ position = Vec(0, 0, -15) }   -- this should match the move-back constant in main.lua
    RelativeTo.World:addChild(master_xform)   -- separate transform is used (not the World defined in main.lua) so that changing the view does not rotate the axes of the cursor. I.e. the cursor's axes never change, so moving the wand toward the screen always causes the cursor to move in the global -z direction.
    master_xform:addChild(cursor.xform)
    Actions.addFrameAction(function()
        while true do
            cursor.xform:setMatrix(cursor:getWandMatrix())
            Actions.waitForRedraw()
        end
    end)
    --[[Actions.addFrameAction(function()
        while true do
            print("Cursor's center: ", cursor.getPosition())
            Actions.waitForRedraw()
        end
    end)]]--
end
