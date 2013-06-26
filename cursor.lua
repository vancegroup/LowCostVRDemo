require "controls"  -- wand

cursor = {}
cursor.geode = osg.Geode()
cursor.geode:addDrawable(osg.ShapeDrawable(osg.Cone(Vecf(0,0,0), 0.1, 0.3)))   -- tip is 0.2 farther in the z direction
cursor.permxform = Transform{ position = {0, -0.2, 0}, orientation = AngleAxis(Degrees(-90), Axis{1.0,0.0,0.0}) }   -- position component adjusts so that the cursor behaves as if the tip is its center
cursor.permxform:addChild(cursor.geode)
cursor.xform = osg.MatrixTransform(wand.matrix)
cursor.xform:addChild(cursor.permxform)
RelativeTo.World:addChild(cursor.xform)
Actions.addFrameAction(function()
    while true do
        cursor.xform:setMatrix(wand.matrix)
        Actions.waitForRedraw()
    end
end)