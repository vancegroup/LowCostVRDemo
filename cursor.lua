require "controls"  -- wand

--[[
    class Cursor
        Only one instance of Cursor is allowed; Cursor is automatically instantiated when this file is "require"d
        This instance is always accessible as the global variable cursor
        
        Vec3f :getPosition()
        Matrixd :getWandMatrix()   -- returns the current wand.matrix adjusted for the set cursor sensitivity. This is the ONLY function allowed to directly access the global 'wand' PositionInterface - everyone else must call this function for all their wand-tracking needs.
        void :changeAppearance(node)   -- pass any node (i.e. Transform, Geode) and it (with all its children, of course) will be rendered as the new cursor image
        
        .defaultAppearance   -- a node to pass to :changeAppearance to restore the default appearance
        -- alternate appearances to be added in the future

        Private members:
        .xform  -- the osg.MatrixTransform used for tracking
        .xform_calibration  -- the osg.MatrixTransform used for calibration. Whatever position/orientation the wand is reporting during program initialization will be taken as the origin for as long as this program runs. Therefore the cursor will start at the origin.
]]--

local CURSOR_SENSITIVITY = 30   -- Higher numbers make smaller wand movements move the cursor farther on-screen. Negative numbers will invert the wand, so don't use them.

cursor = {}

cursor.changeAppearance = function(cursor, geode)
    cursor.xform:removeChildren(0, cursor.xform:getNumChildren())
    cursor.xform:addChild(geode)
end

-- initialize cursor.defaultAppearance
local shapeDrawable = osg.ShapeDrawable(osg.Cone(Vecf(0,0,0), 0.15, 0.4))   -- tip is at (0, 0, 0.3)
shapeDrawable:setColor(Vecf(1.0, 0.5, 0.0, 1.0))
local geode = osg.Geode()
geode:addDrawable(shapeDrawable)
local permxform = Transform{ position = {0, -0.3, 0}, orientation = AngleAxis(Degrees(-90), Axis{1.0,0.0,0.0}) }   -- position component adjusts so that the cursor behaves as if the tip is its center
permxform:addChild(geode)
cursor.defaultAppearance = permxform

cursor.getPosition = function()
    return Vecf(cursor.xform:getWorldMatrices(RelativeTo.World).Item[1]:preMult(Vec(0,0,0)))
end

cursor.getWandMatrix = function()
    local wandMatrix = wand.matrix
    wandMatrix:setTrans(CURSOR_SENSITIVITY*wandMatrix:getTrans())
    return wandMatrix
end

function enableCursor()
    local master_xform = Transform{ position = MASTER_OFFSET_VEC }   -- MASTER_OFFSET_VEC is defined in main.lua
    RelativeTo.World:addChild(master_xform)   -- separate transform is used (not the World defined in main.lua) so that changing the view does not rotate the axes of the cursor. I.e. the cursor's axes never change, so moving the wand toward the screen always causes the cursor to move in the global -z direction.
    cursor.xform = osg.MatrixTransform()
    cursor.xform_calibration = osg.MatrixTransform()
    master_xform:addChild(cursor.xform_calibration)
    cursor.xform_calibration:addChild(cursor.xform)
    
    cursor:changeAppearance(cursor.defaultAppearance)
    
    Actions.addFrameAction(function()
        -- on the first frame take measurements for calibration
        cursor.xform_calibration:setMatrix(osg.Matrixd.inverse(cursor.getWandMatrix()))   -- initially, this will exactly cancel cursor.xform and result in having the cursor at the origin. Returning the wand to its starting position will return the cursor to the origin.
        
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
