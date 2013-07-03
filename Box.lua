require "myObject"

--[[
    class Box: inherits from (and implements) myObject
        Constructors: Box(color)  -- create a new Box of the specified (Vec4f) color using the interactive draw sequence
                      Box(box_to_copy)   -- create a new Box that is an exact duplicate of the one passed
        
        implements abstract methods of myObject
        
        Additional private members:
        .osgbox  -- the underlying osg::Box
]]--

function Box(arg)  -- both constructors in one function. Pass either a Vec4f color for interactive draw, or an existing Box to copy
    copy = (type(arg) == "table")   -- copy will be true if an object to copy was passed, but false if a color was passed
    
    local rawbox;
    if copy then
        rawbox = osg.Box()
        rawbox:setCenter(arg.osgbox:getCenter())  -- due to JuggLua bug, the overloaded constructor can't be called
        rawbox:setHalfLengths(arg.osgbox:getHalfLengths())
    else
        rawbox = osg.Box(Vecf(0,0,0), 0.01)
    end
    
    local box = myObject(rawbox)
    box.osgbox = rawbox
    
    box:setColor(copy and arg:getColor() or arg)
    
    box.getCenterInWorldCoords = Box_getCenterInWorldCoords
    box.initializeScaling = Box_initializeScaling
    box.scale = Box_scale
    box.contains = Box_contains
    box.removeObject = Box_removeObject
    
    if copy then
        box:setCenter(arg:getCenterDisplacement())
        return box
        -- copy complete
    end
    
    -- draw the box
    repeat
        Actions.waitForRedraw()
    until hold_to_draw_button.pressed
    
    local startLoc = Vecf(wand.position)   -- the location the button was first pressed
    box:setCenter(Vec(startLoc))
    RelativeTo.World:addChild(box.attach_here)
    box:openForEditing()
    
    repeat
        local endLoc = Vecf(wand.position)
        box:setCenter(Vec(avgPosf(startLoc, endLoc)))
        local deltax, deltay, deltaz = getDeltas(startLoc, endLoc)
        deltax, deltay, deltaz = 0.5*math.abs(deltax), 0.5*math.abs(deltay), 0.5*math.abs(deltaz)
        if deltax < 0.01 then deltax = 0.01 end  -- disallow halfLengths less than 0.01
        if deltay < 0.01 then deltay = 0.01 end
        if deltaz < 0.01 then deltaz = 0.01 end
        box.osgbox:setHalfLengths(Vecf(deltax, deltay, deltaz))
        Actions.waitForRedraw()
    until not hold_to_draw_button.pressed
    
    -- hold_to_draw_button was released
    
    box:closeForEditing()
    
    -- done creating box
    return box
end

function Box_getCenterInWorldCoords(box)
    return box:getLocalToWorldCoords():preMult(box.osgbox:getCenter())
end

function Box_initializeScaling(box)
    box.initialHalfLengths = box.osgbox.getHalfLengths()
end

function Box_scale(box, newScale)
    box.osgbox:setHalfLengths(Vecf(box.initialHalfLengths:x()*newScale, box.initialHalfLengths:y()*newScale, box.initialHalfLengths:z()*newScale))
end

function Box_contains(box, vec)
    local vecInLocalCoords = box.getWorldToLocalCoords():preMult(vec)
    if vecInLocalCoords:x() > box.osgbox:getCenter():x() + box.osgbox:getHalfLengths():x()
        or vecInLocalCoords:x() < box.osgbox:getCenter():x() - box.osgbox:getHalfLengths():x()
        or vecInLocalCoords:y() > box.osgbox:getCenter():y() + box.osgbox:getHalfLengths():y()
        or vecInLocalCoords:y() < box.osgbox:getCenter():y() - box.osgbox:getHalfLengths():y()
        or vecInLocalCoords:z() > box.osgbox:getCenter():z() + box.osgbox:getHalfLengths():z()
        or vecInLocalCoords:z() < box.osgbox:getCenter():z() - box.osgbox:getHalfLengths():z()
        then return false
    else return true
    end
end

function Box_removeObject(box)
    RelativeTo.World:removeChild(box.attach_here)
end