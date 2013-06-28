require "myObject"

--[[
    class Box: inherits from (and implements) myObject
        Constructor: Box()
        
        implements abstract methods of myObject
        
        Additional private members:
        .osgbox  -- the underlying osg::Box
]]--

function Box()
    print "initializing box."
    local rawbox = osg.Box(Vecf(0,0,0), 0.01)
    local box = myObject(rawbox)
    box.osgbox = rawbox
    
    box.getCenterInWorldCoords = function()
        return box:getLocalToWorldCoords():preMult(box.osgbox:getCenter())
    end
    
    box.initializeScaling = function()
        box.initialHalfLengths = box.osgbox.getHalfLengths()
    end
    
    box.scale = function(_, newScale)
        box.osgbox:setHalfLengths(Vecf(box.initialHalfLengths:x()*newScale, box.initialHalfLengths:y()*newScale, box.initialHalfLengths:z()*newScale))
    end
    
    box.contains = function(_, vec)
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
    print("done creating box")
    return box
end