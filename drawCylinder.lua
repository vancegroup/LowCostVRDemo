require "myTransparentGroup"

device = gadget.PositionInterface('VJWand')
button1 = gadget.DigitalInterface('VJButton1')
button2 = gadget.DigitalInterface('VJButton2')

cursor_geode = osg.Geode()
cursor_geode:addDrawable(osg.ShapeDrawable(osg.Cone(Vecf(0,0,0), 0.1, 0.3)))   -- tip is 0.2 farther in the z direction
cursor_permxform = Transform{ position = {0, -0.2, 0}, orientation = AngleAxis(Degrees(-90), Axis{1.0,0.0,0.0}) }   -- position component adjusts so that the cursor behaves as if the tip is its center
cursor_permxform:addChild(cursor_geode)
cursor_xform = osg.MatrixTransform(device.matrix)
cursor_xform:addChild(cursor_permxform)
RelativeTo.World:addChild(cursor_xform)

Actions.addFrameAction(function()
    repeat
        cursor_xform:setMatrix(device.matrix)
		Actions.waitForRedraw()
    until button1.pressed

    startLoc = Vecf(device.position)   -- the location the button was first pressed
	
	-- initialize the cylinder
	cylinder = osg.Cylinder(startLoc, 0.1, 0.05)
    shapeDrawable = osg.ShapeDrawable(cylinder)
	shapeDrawable:setUseDisplayList(false)  -- force to re-render every frame
    cylinderGeode = osg.Geode()
    cylinderGeode:addDrawable(shapeDrawable)
    local xform = osg.MatrixTransform()
    xform:addChild(cylinderGeode)
    local permxform = Transform{ 
		orientation = AngleAxis(Degrees(-90), Axis{1.0, 0.0, 0.0}) 
	}
	permxform:addChild(xform)
	RelativeTo.World:addChild(permxform)
	
    repeat
		cursor_xform:setMatrix(device.matrix)  -- update cursor position
		local endLoc = Vecf(device.position)
		local centerPos = avgPosf(endLoc,startLoc)
		local deltax = endLoc:x()-startLoc:x()
		--local deltay = endLoc:y()-startLoc:y()
		local deltaz = endLoc:z()-startLoc:z()
		cylinder:setCenter(centerPos)
		local newradius = (deltax^2+deltaz^2)^0.5/2.0  -- the diameter is the xz-distance between startLoc and endLoc. Divide by 2 to get the radius. xz-distance is used because the cylinder expands in the xz-plane and cannot be expanded in y during this step (making the base).
		if (newradius > 0.1) then
			cylinder:setRadius( newradius )
		end
		Actions.waitForRedraw()
    until not button1.pressed
    
    -- button1 was released
	
	initial_cylinder_center = cylinder:getCenter()
	
	repeat
		cursor_xform:setMatrix(device.matrix)
		Actions.waitForRedraw()
	until button1.pressed
	
	-- button1 was pressed the second time
	
	startLoc = Vecf(device.position)
	
	repeat
		cursor_xform:setMatrix(device.matrix)
		local endLoc = Vecf(device.position)
		local deltay = endLoc:y()-startLoc:y()
		if (math.abs(deltay) > 0.05) then
			cylinder:setHeight(deltay)
		end
		cylinder:setCenter(Vecf(initial_cylinder_center:x(), initial_cylinder_center:y()+0.5*deltay, initial_cylinder_center:z()))    -- the center is halfway up the height
		Actions.waitForRedraw()
	until not button1.pressed
	
	-- button1 was released
	
    while true do
        cursor_xform:setMatrix(device.matrix)
		Actions.waitForRedraw()
    end
    
end)

function avgPosf(v1, v2) 
    return Vecf( (v1:x()+v2:x())/2, (v1:y()+v2:y())/2, (v1:z()+v2:z())/2 )
end

function printVec(vec)
    print("x = ", vec:x(), "; y = ", vec:y(), "; z = ", vec:z())
end