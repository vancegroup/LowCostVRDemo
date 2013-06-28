require "myObject"

--[[
    class Sphere: inherits from (and implements) myObject
    Constructor: Sphere()
    
    implements abstract methods of myObject
    
    Additional private members:
    .osgsphere  -- the underlying osg::Sphere
]]--

function Sphere()
    local rawsphere = osg.Sphere(Vecf(0,0,0), 0.01)
    local sphere = myObject(rawsphere)
    sphere.osgsphere = rawsphere
    
    sphere.getCenterInWorldCoords = function()
        return sphere:getLocalToWorldCoords():preMult(sphere.osgsphere:getCenter())
    end
    
    sphere.initializeScaling = function()
        sphere.initialRadius = sphere.osgsphere:getRadius()
    end
    
    sphere.scale = function(_, newScale)
        sphere.osgsphere:setRadius(sphere.initialRadius*newScale)
    end
    
    sphere.contains = function(_, vec)
        local vecInLocalCoords = sphere.getWorldToLocalCoords():preMult(vec)
        local distFromCenter = (vecInLocalCoords - sphere.osgsphere:getCenter()):length()
        if distFromCenter > sphere.osgsphere:getRadius() then return false else return true end
    end
    
    -- draw the sphere
    repeat
        Actions.waitForRedraw()
    until hold_to_draw_button.pressed
    
    local startLoc = Vecf(wand.position)   -- the location the button was first pressed
    sphere:setCenter(Vec(startLoc))
    RelativeTo.World:addChild(sphere.attach_here)
    sphere:openForEditing()
    
    repeat
        local endLoc = Vecf(wand.position)
        sphere:setCenter(Vec(avgPosf(startLoc, endLoc)))
        local newradius = (endLoc - startLoc):length() / 2
        if (newradius > 0.01) then
            sphere.osgsphere:setRadius( newradius )
        end
        Actions.waitForRedraw()
    until not hold_to_draw_button.pressed
    
    -- hold_to_draw_button was released
    
    sphere:closeForEditing()
    
    -- done creating sphere
    return sphere
end