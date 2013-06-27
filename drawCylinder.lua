require "myGrabbable"

--[[
    class Cylinder: inherits from myObject
        Constructor: Cylinder()
        
        implements all methods of myObject
        
        Additional private members:
        .osgcylinder  -- the underlying osg::Cylinder
        .shapeDrawable  -- the osg::ShapeDrawable which the osg::Cylinder is attached to
        .xform  -- a PositionAttitudeTransform, which is responsible for moving the cylinder's center during its construction (rather than cylinder.osgcylinder:setCenter()) such that its center can remain at local (0,0,0), necessary so that it rotates around its local center and to prevent other undesirable effects caused by having the local center displaced from (0,0,0)
]]--

function Cylinder()
    local rawcylinder = osg.Cylinder(Vecf{0,0,0}, 0.1, 0.05)
    local shapeDrawable = osg.ShapeDrawable(rawcylinder)
    local geode = osg.Geode()
    geode:addDrawable(shapeDrawable)
    local permxform = Transform{
        orientation = AngleAxis(Degrees(-90), Axis{1.0, 0.0, 0.0})
    }
    permxform:addChild(geode)
    local cylinder = myGrabbable(permxform, wand)
    cylinder.osgcylinder = rawcylinder
    cylinder.shapeDrawable = shapeDrawable
    cylinder.xform = Transform{ position = {0,0,0} }
    cylinder.xform:addChild(cylinder.attach_here)
    
    cylinder.selected = false
    
    cylinder.getCenter = function()
        return cylinder.getLocalToWorldCoords():preMult(cylinder.osgcylinder:getCenter())
    end

    cylinder.initializeScaling = function()
        cylinder.initialRadius = cylinder.osgcylinder:getRadius()
        cylinder.initialHeight = cylinder.osgcylinder:getHeight()
    end

    cylinder.scale = function(_, newScale)   -- _ will actually be the cylinder object, but we're just using our local copy 
        cylinder.osgcylinder:setRadius(cylinder.initialRadius*newScale)
        cylinder.osgcylinder:setHeight(cylinder.initialHeight*newScale)
    end

    cylinder.openForEditing = function()
        cylinder.shapeDrawable:setUseDisplayList(false)   -- cylinder needs to be re-rendered every frame while it is changed
    end

    cylinder.closeForEditing = function() 
        cylinder.shapeDrawable:setUseDisplayList(true)    -- done modifying cylinder, doesn't need to be re-rendered every frame
    end
    
    cylinder.contains = function(_, vec)
        local vecInLocalCoords = cylinder.getWorldToLocalCoords():preMult(vec)
        print("vecInLocalCoords calculated as "); printVec(vecInLocalCoords)
        reportStats(cylinder)
        if vecInLocalCoords:y() > cylinder.osgcylinder:getCenter():y()+0.5*cylinder.osgcylinder:getHeight()
            or vecInLocalCoords:y() < cylinder.osgcylinder:getCenter():y()-0.5*cylinder.osgcylinder:getHeight()
            then print("Too high or too low"); return false
        end
        local deltax, deltay, deltaz = getDeltas(vecInLocalCoords, cylinder.osgcylinder:getCenter())
        local xzDistanceFromCenter = (deltax^2+deltaz^2)^0.5
        if xzDistanceFromCenter > cylinder.osgcylinder:getRadius() then return false end
        return true
    end
    
    -- draw the cylinder
    repeat
        print("Cursor position is "); printVec(cursor.getPosition())
        Actions.waitForRedraw()
    until hold_to_draw_button.pressed

    local startLoc = Vecf(wand.position)   -- the location the button was first pressed
    cylinder.xform:setPosition(Vec(startLoc))   -- xform is used rather than cylinder.osgcylinder:setCenter() to adjust the center-position of the cylinder. See note above on the class member .xform.
    RelativeTo.World:addChild(cylinder.xform)   -- cylinder.xform is the outermost node in the Cylinder construct
    cylinder:openForEditing()
    
    repeat
        local endLoc = Vecf(wand.position)
        local centerPos = avgPosf_lock_y(startLoc, endLoc)
        local deltax, deltay, deltaz = getDeltas(startLoc, endLoc)
        cylinder.xform:setPosition(Vec(centerPos))
        local newradius = (deltax^2+deltaz^2)^0.5/2.0  -- the diameter is the xz-distance between startLoc and endLoc. Divide by 2 to get the radius. xz-distance is used because the cylinder expands in the xz-plane and cannot be expanded in y during this step (making the base).
        if (newradius > 0.1) then
            cylinder.osgcylinder:setRadius( newradius )
        end
        reportStats(cylinder)
        Actions.waitForRedraw()
    until not hold_to_draw_button.pressed

    -- hold_to_draw_button was released

    local initial_cylinder_center = cylinder.xform:getPosition()

    repeat
        Actions.waitForRedraw()
    until hold_to_draw_button.pressed

    -- hold_to_draw_button was pressed the second time

    startLoc = Vecf(wand.position)

    repeat
        local endLoc = Vecf(wand.position)
        local deltay = endLoc:y()-startLoc:y()
        if (math.abs(deltay) > 0.05) then
            cylinder.osgcylinder:setHeight(deltay)
        end
        cylinder.xform:setPosition(Vec(initial_cylinder_center:x(), initial_cylinder_center:y()+0.5*deltay, initial_cylinder_center:z()))    -- the center is halfway up the height
        reportStats(cylinder)
        Actions.waitForRedraw()
    until not hold_to_draw_button.pressed

    -- hold_to_draw_button was released
    
    cylinder:closeForEditing()
    
    -- done creating cylinder
    return cylinder
end

function avgPosf(v1, v2)
    return Vecf( (v1:x()+v2:x())/2, (v1:y()+v2:y())/2, (v1:z()+v2:z())/2 )
end

function avgPosf_lock_y(v1, v2)
    return Vecf( (v1:x()+v2:x())/2, v1:y(), (v1:z()+v2:z())/2 )
end

function getDeltas(startVec, endVec)
    return endVec:x() - startVec:x(), endVec:y() - startVec:y(), endVec:z() - startVec:z()
end

-- no longer used functions
--[[
function angleDegreesBetween(v1, v2)
    return math.acos((dot_prod_3(v1,v2))/(v1:length()*v2:length()))*180/math.pi
end

function dot_prod_3(v1, v2)
    return v1:x()*v2:x() + v1:y()*v2:y() + v1:z()*v2:z()
end

function x_prod(vec1, vec2)
    return Vecf( vec1:y()*vec2:z() - vec1:z()*vec2:y(), vec1:z()*vec2:x() - vec1:x()*vec2:z(), vec1:x()*vec2:y() - vec1:y()*vec2:x() )
end
]]--

-- debugging
function printVec(vec)
    print("x = ", vec:x(), "; y = ", vec:y(), "; z = ", vec:z())
end

function reportStats(cylinder)
    print("Cylinder stats: Center is "); printVec(cylinder.osgcylinder:getCenter()); print("in local coordinates; or in world coordinates it is "); printVec(cylinder:getCenter()); print("Height is ", cylinder.osgcylinder:getHeight(), " and radius is ", cylinder.osgcylinder:getRadius())
end