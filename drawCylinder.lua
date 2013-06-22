device = gadget.PositionInterface('VJWand')
button1 = gadget.DigitalInterface('VJButton1')

cursor_geode = osg.Geode()
cursor_geode:addDrawable(osg.ShapeDrawable(osg.Cone(Vecf(0,0,0), 0.1, 0.3)))   -- tip is 0.2 farther in the z direction
cursor_xform = osg.MatrixTransform(device.matrix)
cursor_xform:addChild(cursor_geode)
cursor_permxform = Transform{ orientation = AngleAxis(Degrees(-90), Axis{1.0,0.0,0.0}) }
cursor_permxform:addChild(cursor_xform)
RelativeTo.World:addChild(cursor_permxform)

Actions.addFrameAction(function()
    repeat
        cursor_xform:setMatrix(device.matrix)
		Actions.waitForRedraw()
    until button1.pressed

    startLoc = Vecf(device.position)
    print("startLoc received.")
    printVec(startLoc)
    
	cylinder = osg.Cylinder(startLoc, 0.1, 0.05)
    shapeDrawable = osg.ShapeDrawable(cylinder)
	shapeDrawable:setUseDisplayList(false)  -- force to re-render every frame
    cylinderGeode = osg.Geode()
    cylinderGeode:addDrawable(shapeDrawable)
    local xform = osg.MatrixTransform()
    xform:addChild(cylinderGeode)
    local permxform = Transform{ 
		position = {0,0.2,0},
		orientation = AngleAxis(Degrees(-90), Axis{1.0, 0.0, 0.0}) 
	}
	permxform:addChild(xform)
	RelativeTo.World:addChild(permxform)
	
    repeat
		cursor_xform:setMatrix(device.matrix)
		local endLoc = Vecf(device.position)
		local centerPos = avgPosf(endLoc,startLoc)
		local deltax = endLoc:x()-startLoc:x()
		local deltay = endLoc:y()-startLoc:y()
		local deltaz = endLoc:z()-startLoc:z()
		cylinder:setCenter(centerPos)
		local newradius = (deltax^2+deltaz^2)^0.5/2.0
		if (newradius > 0.1) then
			cylinder:setRadius( newradius )
			print("updated radius")
		end
		print("updated cylinder: \ncenter: "); printVec(cylinder:getCenter()); print("radius: ", cylinder:getRadius())
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