require "ShapeObjects.ShapeObject"

--[[
    class Sphere: inherits from (and implements) ShapeObject
        Constructors: Sphere(color)  -- create a new Sphere of the specified (Vec4f) color using the interactive draw sequence
                      Sphere(sphere_to_copy)   -- create a new Sphere that is an exact duplicate of the one passed
        
        implements abstract methods of myObject
        
        Additional private members:
        .osgsphere  -- the underlying osg::Sphere
]]--

function Sphere(arg)  -- both constructors in one function. Pass either a Vec4f color for interactive draw, or an existing Sphere to copy
    copy = (type(arg) == "table")   -- copy will be true if an object to copy was passed, but false if a color was passed
    
    local rawsphere; 
    if copy then
        rawsphere = osg.Sphere(arg.osgsphere:getCenter(), arg.osgsphere:getRadius())
    else
        rawsphere = osg.Sphere(Vecf(0,0,0), 0.01)
    end
    
    local sphere = ShapeObject(rawsphere)
    sphere.osgsphere = rawsphere
    
    sphere:setColor(copy and arg:getColor() or arg)  -- arg could be either a Sphere or a color
    
    sphere.getCenterInWorldCoords = Sphere_getCenterInWorldCoords
    sphere.initializeScaling = Sphere_initializeScaling
    sphere.scale = Sphere_scale
    sphere.contains = Sphere_contains
    sphere.removeObject = Sphere_removeObject
    
    if copy then
        sphere:setCenter(arg:getCenterDisplacement())
        RelativeTo.World:addChild(sphere.attach_here)
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
    local vecInLocalCoords = sphere:getWorldToLocalCoords():preMult(vec)
    local distFromCenter = (vecInLocalCoords - sphere.osgsphere:getCenter()):length()
    if distFromCenter > sphere.osgsphere:getRadius() then return false else return true end
end

function Sphere_removeObject(sphere)
    RelativeTo.World:removeChild(sphere.attach_here)
end