require "myObject"

--[[
    class Cylinder: inherits from (and implements) myObject
        Constructor: Cylinder()
        
        implements all methods of myObject
        
        Additional private members:
        .osgcylinder  -- the underlying osg::Cylinder
]]--

function Cylinder()
    local rawcylinder = osg.Cylinder(Vecf{0,0,0}, 0.1, 0.05)
    local cylinder = myObject(rawcylinder, Transform{ orientation = AngleAxis(Degrees(-90), Axis{1.0, 0.0, 0.0}) })
    cylinder.osgcylinder = rawcylinder
    
    cylinder.getCenterInWorldCoords = function()
        return cylinder:getLocalToWorldCoords():preMult(cylinder.osgcylinder:getCenter())
    end

    cylinder.initializeScaling = function()
        cylinder.initialRadius = cylinder.osgcylinder:getRadius()
        cylinder.initialHeight = cylinder.osgcylinder:getHeight()
    end

    cylinder.scale = function(_, newScale)   -- _ will actually be the cylinder object, but we're just using our local copy 
        cylinder.osgcylinder:setRadius(cylinder.initialRadius*newScale)
        cylinder.osgcylinder:setHeight(cylinder.initialHeight*newScale)
    end

    cylinder.contains = function(_, vec)
        local vecInLocalCoords = cylinder.getWorldToLocalCoords():preMult(vec)
        --print("vecInLocalCoords calculated as "); printVec(vecInLocalCoords)
        --reportStats(cylinder)
        if vecInLocalCoords:y() > cylinder.osgcylinder:getCenter():y()+0.5*cylinder.osgcylinder:getHeight()
            or vecInLocalCoords:y() < cylinder.osgcylinder:getCenter():y()-0.5*cylinder.osgcylinder:getHeight()
            then return false
        end
        local deltax, deltay, deltaz = getDeltas(vecInLocalCoords, cylinder.osgcylinder:getCenter())
        local xzDistanceFromCenter = (deltax^2+deltaz^2)^0.5
        if xzDistanceFromCenter > cylinder.osgcylinder:getRadius() then return false end
        return true
    end
    
    -- draw the cylinder
    repeat
        --print("Cursor position is "); printVec(cursor.getPosition())
        Actions.waitForRedraw()
    until hold_to_draw_button.pressed

    local startLoc = Vecf(wand.position)   -- the location the button was first pressed
    local centerPos = startLoc
    cylinder:setCenter(Vec(startLoc))
    RelativeTo.World:addChild(cylinder.attach_here)
    cylinder:openForEditing()
    
    repeat
        local endLoc = Vecf(wand.position)
        centerPos = avgPosf_lock_y(startLoc, endLoc)
        local deltax, deltay, deltaz = getDeltas(startLoc, endLoc)
        cylinder:setCenter(Vec(centerPos))
        local newradius = (deltax^2+deltaz^2)^0.5/2.0  -- the diameter is the xz-distance between startLoc and endLoc. Divide by 2 to get the radius. xz-distance is used because the cylinder expands in the xz-plane and cannot be expanded in y during this step (making the base).
        if (newradius > 0.1) then
            cylinder.osgcylinder:setRadius( newradius )
        end
        --reportStats(cylinder)
        Actions.waitForRedraw()
    until not hold_to_draw_button.pressed

    -- hold_to_draw_button was released

    repeat
        Actions.waitForRedraw()
    until hold_to_draw_button.pressed

    -- hold_to_draw_button was pressed the second time

    startLoc = Vecf(wand.position)

    repeat
        local endLoc = Vecf(wand.position)
        local deltay = endLoc:y()-startLoc:y()
        if (math.abs(deltay) > 0.05) then
            cylinder.osgcylinder:setHeight(math.abs(deltay))
        end
        cylinder:setCenter(Vec(centerPos:x(), centerPos:y()+0.5*deltay, centerPos:z()))    -- the center is halfway up the height
        --reportStats(cylinder)
        Actions.waitForRedraw()
    until not hold_to_draw_button.pressed

    -- hold_to_draw_button was released
    
    cylinder:closeForEditing()
    
    -- done creating cylinder
    return cylinder
end

-- debugging
function reportStats(cylinder)
    print("Cylinder stats: Center is "); printVec(cylinder.osgcylinder:getCenter()); print("in local coordinates; or in world coordinates it is "); printVec(cylinder:getCenterInWorldCoords()); print("Height is ", cylinder.osgcylinder:getHeight(), " and radius is ", cylinder.osgcylinder:getRadius())
end