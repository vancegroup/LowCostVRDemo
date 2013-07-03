require "myObject"

--[[
    class Cone: inherits from (and implements) myObject
        Constructors: Cone(color)  -- create a new Cone of the specified (Vec4f) color using the interactive draw sequence
                      Cone(cone_to_copy)   -- create a new Cone that is an exact duplicate of the one passed
        
        implements abstract methods of myObject
        
        Additional private members:
        .osgcone  -- the underlying osg::Cone
        float :getRadiusAtPercentHeight(float)  -- pass the percent up the height, where 1 is the tip and 0 is the base, receive the radius at that height
]]--

function Cone(arg)  -- both constructors in one function. Pass either a Vec4f color for interactive draw, or an existing Cone to copy
    copy = (type(arg) == "table")   -- copy will be true if an object to copy was passed, but false if a color was passed
    
    local rawcone; 
    if copy then
        rawcone = osg.Cone(arg.osgcone:getCenter(), arg.osgcone:getRadius(), arg.osgcone:getHeight())
    else
        rawcone = osg.Cone(Vecf(0,0,0), 0.05, 0.01)
    end
    local cone = myObject(rawcone, Transform{ orientation = AngleAxis(Degrees(-90), Axis{1.0, 0.0, 0.0}) })
    cone.osgcone = rawcone
    
    cone:setColor(copy and arg:getColor() or arg)  -- arg could be either a Cone or a color
    
    cone.getCenterInWorldCoords = Cone_getCenterInWorldCoords
    cone.initializeScaling = Cone_initializeScaling
    cone.scale = Cone_scale
    cone.contains = Cone_contains
    cone.removeObject = Cone_removeObject
    
    cone.getRadiusAtPercentHeight = Cone_getRadiusAtPercentHeight
    
    if copy then
        cone:setCenter(arg:getCenterDisplacement())
        return cone
        -- copy complete
    end
    
    -- draw the cone
    repeat
        Actions.waitForRedraw()
    until hold_to_draw_button.pressed
    
    local startLoc = Vecf(wand.position)   -- the location the button was first pressed
    local centerPos = startLoc
    cone:setCenter(Vec(startLoc))
    RelativeTo.World:addChild(cone.attach_here)
    cone:openForEditing()
    
    repeat
        local endLoc = Vecf(wand.position)
        centerPos = avgPosf_lock_y(startLoc, endLoc)
        local deltax, deltay, deltaz = getDeltas(startLoc, endLoc)
        cone:setCenter(Vec(centerPos))
        local newradius = (deltax^2+deltaz^2)^0.5/2.0  -- the diameter is the xz-distance between startLoc and endLoc. Divide by 2 to get the radius. xz-distance is used because the cone expands in the xz-plane and cannot be expanded in y during this step (making the base).
        if (newradius > 0.1) then
            cone.osgcone:setRadius( newradius )
        end
        Actions.waitForRedraw()
    until not hold_to_draw_button.pressed
    
    -- hold_to_draw_button was released

    repeat
        Actions.waitForRedraw()
    until hold_to_draw_button.pressed

    -- hold_to_draw_button was pressed the second time

    startLoc = Vecf(wand.position)
    
    -- centerPos persists as the coordinates of the center of the base of the cone
    repeat
        local endLoc = Vecf(wand.position)
        local deltay = endLoc:y()-startLoc:y()
        if deltay > 0.01 then
            cone.osgcone:setHeight(deltay)
            cone:setCenter(Vec(centerPos:x(), centerPos:y()+0.25*deltay, centerPos:z()))    -- the center is 25% of the way up the height
        end
        Actions.waitForRedraw()
    until not hold_to_draw_button.pressed

    -- hold_to_draw_button was released
    
    cone:closeForEditing()
    
    -- done creating cone
    return cone
end

function Cone_getCenterInWorldCoords(cone)
    return cone:getLocalToWorldCoords():preMult(cone.osgcone:getCenter())
end

function Cone_initializeScaling(cone)
    cone.initialRadius = cone.osgcone:getRadius()
    cone.initialHeight = cone.osgcone:getHeight()
end

function Cone_scale(cone, newScale)
    cone.osgcone:setRadius(cone.initialRadius*newScale)
    cone.osgcone:setHeight(cone.initialHeight*newScale)
end

function Cone_contains(cone, vec)
    local vecInLocalCoords = cone.getWorldToLocalCoords():preMult(vec)
    local heightUpFromBase = vecInLocalCoords:y() - (cone.osgcone:getCenter():y()-0.25*cone.osgcone:getHeight())   -- center is at the center of mass of the cone, 25% of the way up from the base
    local percentHeight = heightUpFromBase / cone.osgcone:getHeight()
    if percentHeight > 1 or percentHeight < 0 then -- too high or too low to hit the cone
        return false
    else
        local radius = cone:getRadiusAtPercentHeight(percentHeight)
        local deltax, deltay, deltaz = getDeltas(vecInLocalCoords, cone.osgcone:getCenter())
        local xzDistanceFromCenter = (deltax^2+deltaz^2)^0.5
        if xzDistanceFromCenter > radius then
            return false
        else
            return true
        end
    end
end

function Cone_removeObject(cone)
    RelativeTo.World:removeChild(cone.attach_here)
end

function Cone_getRadiusAtPercentHeight(cone, percent)
        return (1.0-percent)*cone.osgcone:getRadius()
    end