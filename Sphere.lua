require "myObject"

--[[
    class Sphere: inherits from (and implements) myObject
    Constructors: Sphere()  -- create a new Sphere using the interactive draw sequence
                  Sphere(sphere_to_copy)   -- create a new Sphere that is an exact duplicate of the one passed
    
    implements abstract methods of myObject
    
    Additional private members:
    .osgsphere  -- the underlying osg::Sphere
]]--

function Sphere(sphere_to_copy)
    local rawsphere; 
    if sphere_to_copy then
        rawsphere = osg.Sphere(sphere_to_copy.osgsphere:getCenter(), sphere_to_copy.osgsphere:getRadius())
    else
        rawsphere = osg.Sphere(Vecf(0,0,0), 0.01)
    end
    
    local sphere = myObject(rawsphere)
    sphere.osgsphere = rawsphere
    
    sphere.getCenterInWorldCoords = Sphere_getCenterInWorldCoords
    sphere.initializeScaling = Sphere_initializeScaling
    sphere.scale = Sphere_scale
    sphere.contains = Sphere_contains
    sphere.removeObject = Sphere_removeObject
    
    if sphere_to_copy then
        sphere:setCenter(sphere_to_copy:getCenterDisplacement())
        return sphere
        -- copy complete
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

function Sphere_getCenterInWorldCoords(sphere)
    return sphere:getLocalToWorldCoords():preMult(sphere.osgsphere:getCenter())
end

function Sphere_initializeScaling(sphere)
    sphere.initialRadius = sphere.osgsphere:getRadius()
end

function Sphere_scale(sphere, newScale)
    sphere.osgsphere:setRadius(sphere.initialRadius*newScale)
end

function Sphere_contains(sphere, vec)
    local vecInLocalCoords = sphere.getWorldToLocalCoords():preMult(vec)
    local distFromCenter = (vecInLocalCoords - sphere.osgsphere:getCenter()):length()
    if distFromCenter > sphere.osgsphere:getRadius() then return false else return true end
end

function Sphere_removeObject(sphere)
    RelativeTo.World:removeChild(sphere.attach_here)
end