require "controls"  -- wand

--[[
    class Cursor
        Only one instance of Cursor is allowed; Cursor is automatically instantiated when this file is "require"d
        This instance is always accessible as the global variable cursor
        
        Matrixd :getPose()  -- get the position and orientation matrix for the cursor with respect to global coordinates.
        Vec3f :getPosition()  -- get just the position information as above.
        Matrixd :getWandMatrix()   -- returns the current wand.matrix. Adjustments can be made to it if desired; the current implementation as of this writing doesn't make any adjustments. This is the ONLY function allowed to directly access the global 'wand' PositionInterface - everyone else must call this function for all their wand-tracking needs.
        void :changeAppearance(node)   -- pass any node (i.e. Transform, Geode) and it (with all its children, of course) will be rendered as the new cursor image
        void :pause()  -- cursor will stay locked in place despite movement of wand, until call to :unpause()
        void :unpause()
        
        .defaultAppearance   -- a node to pass to :changeAppearance to restore the default appearance
        -- alternate appearances to be added in the future

        Private members:
        .xform  -- the osg.MatrixTransform used for tracking
        .xform_calibration  -- the osg.MatrixTransform used for calibration. Whatever position/orientation the wand is reporting during program initialization will be taken as the origin for as long as this program runs. Therefore the cursor will start at the origin.
        .paused  -- whether the cursor is paused or not
]]--

cursor = {}

cursor.changeAppearance = function(cursor, geode)
    cursor.xform:removeChildren(0, cursor.xform:getNumChildren())
    cursor.xform:addChild(geode)
end

cursor.pause = function()
    cursor.paused = true
end

cursor.unpause = function()
    cursor.paused = false
end

-- initialize cursor.defaultAppearance
local shapeDrawable = osg.ShapeDrawable(osg.Cone(Vecf(0,0,0), 0.015, 0.04))   -- tip is at (0, 0, 0.03)
shapeDrawable:setColor(Vecf(1.0, 0.5, 0.0, 1.0))
local geode = osg.Geode()
geode:addDrawable(shapeDrawable)
local permxform = Transform{
    position = {0, 0, 0.03},  -- adjusts so that the cursor behaves as if the tip is its center
    orientation = AngleAxis(Degrees(-180), Axis{1.0,0.0,0.0}),
    geode
}
cursor.defaultAppearance = permxform

cursor.getPose = function()
    return cursor.xform:getWorldMatrices().Item[1]
end

cursor.getPosition = function()
    return Vecf(cursor:getPose():getTrans())
end

cursor.getWandMatrix = function()
    return wand.matrix
end

function enableCursor()
    cursor.xform = MatrixTransform{}
    RelativeTo.Room:addChild(
        Transform{
            position = {0,0,-1};
            cursor.xform
        }
    )
    
    cursor:changeAppearance(cursor.defaultAppearance)
    cursor:unpause()
    
    Actions.addFrameAction(function()        
        while true do
            cursor.xform:setMatrix(cursor:getWandMatrix())
            repeat
                Actions.waitForRedraw()
            until not cursor.paused
        end
    end)
    
    --[[Actions.addFrameAction(function()
        while true do
            print("Cursor's center: ", cursor.getPosition())
            Actions.waitForRedraw()
        end
    end)]]--
end
