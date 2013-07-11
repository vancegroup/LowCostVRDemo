require "controls"  -- wand

--[[
    class Cursor
        Constructor Cursor()   -- initialize the cursor to default appearance
        
        Vec3f :getPosition()
        void :changeAppearance(node)   -- pass any node (i.e. Transform, Geode) and it will be rendered as the new cursor image
        
        .defaultAppearance   -- a node to pass to :changeAppearance that contains the default appearance parameters
        -- alternate appearances to be added in the future
]]--

function Cursor()

    local cursor = {}

    local xform = osg.MatrixTransform(wand.matrix)

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
        return Vecf(xform:getWorldMatrices(RelativeTo.World).Item[1]:preMult(Vec(0,0,0)))
    end
    
    cursor:changeAppearance(cursor.defaultAppearance)
    World:addChild(xform)
    Actions.addFrameAction(function()
        while true do
            xform:setMatrix(wand.matrix)
            Actions.waitForRedraw()
        end
    end)
    
    return cursor
end