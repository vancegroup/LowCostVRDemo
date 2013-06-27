device = gadget.PositionInterface('VJWand')

cube = osg.Box(Vecf(0.5, 0.5, 0.5), 0.1, 0.5, 0.3)
shapeDrawable = osg.ShapeDrawable(cube)
shapeDrawable:setColor(osg.Vec4f(0.0, 0.0, 1.0, 0.0))
cubeGeode = osg.Geode()
cubeGeode:addDrawable(shapeDrawable)
local xform = osg.MatrixTransform()
xform:addChild(cubeGeode)
RelativeTo.World:addChild(xform)

Actions.addFrameAction(function()
    -- update based on cursor
    while true do
        xform:setMatrix(device.matrix)
		Actions.waitForRedraw()
    end
end)