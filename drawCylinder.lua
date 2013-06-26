require "myGrabbable"

function createCylinder()  -- creates and returns a Cylinder, functionally a subclass of myObject (see runloop.lua)
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
    
    cylinder.selected = false
    
    cylinder.getCenter = function()
        return cylinder.osgcylinder:getCenter()
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
    
    -- draw the cylinder
    repeat
            Actions.waitForRedraw()
    until hold_to_draw_button.pressed

    local startLoc = Vecf(wand.position)   -- the location the button was first pressed
    cylinder.osgcylinder:setCenter(startLoc)
    RelativeTo.World:addChild(cylinder.attach_here)
    cylinder:openForEditing()
    
    repeat
        local endLoc = Vecf(wand.position)
        local centerPos = avgPosf(startLoc, endLoc)
        local deltax, deltay, deltaz = getDeltas(startLoc, endLoc)
        cylinder.osgcylinder:setCenter(centerPos)
        local newradius = (deltax^2+deltaz^2)^0.5/2.0  -- the diameter is the xz-distance between startLoc and endLoc. Divide by 2 to get the radius. xz-distance is used because the cylinder expands in the xz-plane and cannot be expanded in y during this step (making the base).
        if (newradius > 0.1) then
            cylinder.osgcylinder:setRadius( newradius )
        end
        Actions.waitForRedraw()
    until not hold_to_draw_button.pressed

    -- hold_to_draw_button was released

    initial_cylinder_center = cylinder:getCenter()

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
        cylinder.osgcylinder:setCenter(Vecf(initial_cylinder_center:x(), initial_cylinder_center:y()+0.5*deltay, initial_cylinder_center:z()))    -- the center is halfway up the height
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
]]--

-- debugging
function printVec(vec)
    print("x = ", vec:x(), "; y = ", vec:y(), "; z = ", vec:z())
end