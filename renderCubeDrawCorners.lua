device = gadget.PositionInterface('VJWand')
button1 = gadget.DigitalInterface('VJButton1')

Actions.addFrameAction(function()
    while not button1.pressed do
        Actions.waitForRedraw()
    end
    
    -- button1 was just pressed
    startLoc = Vecf(device.position)
    print("startLoc received.")
    printVec(startLoc)
    
    while button1.pressed do
        Actions.waitForRedraw()
    end
    
    -- button1 was released
    
    while not button1.pressed do
        Actions.waitForRedraw()
    end
    
    -- button1 was pressed again
    endLoc = Vecf(device.position)
    print("endLoc received.")
    printVec(endLoc)

    centerPos = avgPosf(endLoc,startLoc)
    print("centerPos:")
    printVec(centerPos)
    
    deltax = endLoc:x()-startLoc:x()
    print("deltax: ")
    print(deltax)
    
    deltay = endLoc:y()-startLoc:y()
    print("deltay: ")
    print(deltay)
    
    deltaz = endLoc:z()-startLoc:z()
    print("deltaz: ")
    print(deltaz)

    cube = osg.Box(centerPos, 10, 10, 5) --deltax, deltay, deltaz)
    shapeDrawable = osg.ShapeDrawable(cube)
    cubeGeode = osg.Geode()
    cubeGeode:addDrawable(shapeDrawable)
    local xform = osg.MatrixTransform()
    xform:addChild(cubeGeode)
    RelativeTo.World:addChild(xform)
    
    -- update based on cursor
    while true do
        xform:setMatrix(device.matrix)
		Actions.waitForRedraw()
    end
    
end)

function avgPosf(v1, v2) 
    return Vecf( (v1:x()+v2:x())/2, (v1:y()+v2:y())/2, (v1:z()+v2:z())/2 )
end

function printVec(vec)
    print("x = ", vec:x(), "; y = ", vec:y(), "; z = ", vec:z())
end