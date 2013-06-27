require "controls"  -- wand

--[[
    class Cursor
        Constructor Cursor()   -- initialize the cursor to default appearance
        
        Vec3f :getPosition()
        void :changeAppearance(node)   -- pass any node (i.e. Transform, Geode) and it will be rendered as the new cursor image
]]--

function Cursor()

    local cursor = {}

    local xform = osg.MatrixTransform(wand.matrix)

    cursor.changeAppearance = function(cursor, geode)
        xform:removeChildren(0, xform:getNumChildren())
        xform:addChild(geode)
    end
    
    cursor.getPosition = function()
        return Vecf(xform:getWorldMatrices(RelativeTo.World).Item[1]:getTrans())
    end
    
    RelativeTo.World:addChild(xform)
    Actions.addFrameAction(function()
        while true do
            xform:setMatrix(wand.matrix)
            Actions.waitForRedraw()
        end
    end)
    
    -- set the initial appearance of the cursor
    local geode = osg.Geode()
    geode:addDrawable(osg.ShapeDrawable(osg.Cone(Vecf(0,0,0), 0.1, 0.3)))   -- tip is 0.2 farther in the z direction
    local permxform = Transform{ position = {0, -0.2, 0}, orientation = AngleAxis(Degrees(-90), Axis{1.0,0.0,0.0}) }   -- position component adjusts so that the cursor behaves as if the tip is its center
    permxform:addChild(geode)
    cursor:changeAppearance(permxform)
    
    return cursor
end