device = gadget.PositionInterface('VJWand')

shapes = osg.CompositeShape()
shapeDrawable = osg.ShapeDrawable(shapes)
cone = osg.Cone(Vecf(0.5, 0.5, 0.5), 0.1, 0.5)
box = osg.Box(Vecf(0.5, 0.5, 0.5), 0.1, 0.5, 0.3)
shapes:addChild(cone)
shapes:addChild(box)

print(shapes:getNumChildren())

shapesGeode = osg.Geode()
shapesGeode:addDrawable(shapeDrawable)
local xform = osg.MatrixTransform()
xform:addChild(shapesGeode)
RelativeTo.World:addChild(xform)

Actions.addFrameAction(function()
    -- update based on cursor
    while true do
        xform:setMatrix(device.matrix)
		Actions.waitForRedraw()
    end
end)
