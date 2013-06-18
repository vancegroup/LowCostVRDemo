device = gadget.PositionInterface('VJWand')
button1 = gadget.DigitalInterface('VJButton1')

Actions.addFrameAction(function()
    while not button1.pressed do
        Actions.waitForRedraw()
    end
    
    -- button1 was just pressed
    startLoc = Vecf(device.position)
    print("startLoc received. x = ")
    print(startLoc:x())
    print("y = ")
    print(startLoc:y())
    print("z = ")
    print(startLoc:z())
    
    while button1.pressed do
        Actions.waitForRedraw()
    end
    
    -- button1 was released
    
    while not button1.pressed do
        Actions.waitForRedraw()
    end
    
    -- button1 was pressed again
    endLoc = Vecf(device.position)
    print("endLoc received. x = ")
    print(endLoc:x())
    print("y = ")
    print(endLoc:y())
    print("z = ")
    print(endLoc:z())
    cube = osg.Box(endLoc-startLoc, endLoc:x()-startLoc:x(), endLoc:y()-startLoc:y(), endLoc:z()-startLoc:z())
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
