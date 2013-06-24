require "myTransparentGroup"

device = gadget.PositionInterface("VJWand")
selectButton = gadget.DigitalInterface("VJButton1")

model_1 = myTransparentGroup{ alpha = 1.0, Model("sparta_models/Clutch-FlywheelPart1.ive") }
model_2 = myTransparentGroup{ alpha = 1.0, Model("sparta_models/Clutch-FlywheelPart2.ive") }
model_3 = myTransparentGroup{ alpha = 1.0, Model("sparta_models/Clutch-FlywheelPart3.ive") }
model_4 = myTransparentGroup{ alpha = 1.0, Model("sparta_models/Clutch-FlywheelPart4.ive") }
--cursor_geode = osg.Geode()
--cursor_geode:addDrawable(osg.ShapeDrawable(osg.Cone(Vecf(0,0,0), 0.1, 0.3)))   -- tip is 0.2 farther in the z direction

xform1 = osg.MatrixTransform()
xform2 = osg.MatrixTransform()
xform3 = osg.MatrixTransform()
xform4 = osg.MatrixTransform()
--cursor_xform = osg.MatrixTransform()

xform1:addChild(model_1)
xform2:addChild(model_2)
xform3:addChild(model_3)
xform4:addChild(model_4)
--cursor_xform:addChild(cursor_geode)

xform_save_1 = osg.MatrixTransform(osg.Matrixd.identity())  -- identity() is a static method for the osg.Matrixd class.
xform_save_2 = osg.MatrixTransform(osg.Matrixd.identity())
xform_save_3 = osg.MatrixTransform(osg.Matrixd.identity())
xform_save_4 = osg.MatrixTransform(osg.Matrixd.identity())

xform_save_1:addChild(xform1)
xform_save_2:addChild(xform2)
xform_save_3:addChild(xform3)
xform_save_4:addChild(xform4)

RelativeTo.World:addChild(xform_save_1)
RelativeTo.World:addChild(xform_save_2)
RelativeTo.World:addChild(xform_save_3)
RelativeTo.World:addChild(xform_save_4)
--RelativeTo.World:addChild(cursor_xform)

Actions.addFrameAction(function()
	
	-- this moves all the parts to the wand's position to start. The operation is done for xform_save_1 at the beginning of the while loop below.
	xform_save_2:postMult(osg.Matrixd.inverse(device.matrix))
	xform_save_3:postMult(osg.Matrixd.inverse(device.matrix))
	xform_save_4:postMult(osg.Matrixd.inverse(device.matrix))
	
	while true do
		
		changeTransparency(model_4, 1.0)
		xform_save_4:postMult(device.matrix)  -- save current position by updating the xform_save transform
		xform4:setMatrix(osg.Matrixd.identity())   -- what was formerly xform_save_4 * xform4 is now stored in xform_save_4; and xform4 is identity
		changeTransparency(model_1, 0.2)
		xform_save_1:postMult(osg.Matrixd.inverse(device.matrix))   -- prevent new item from "jumping" by compensating for current position of cursor
		print("Part 1 is selected.")
		
		repeat
			xform1:setMatrix(device.matrix)
			--cursor_xform:setMatrix(device.matrix)
			Actions.waitForRedraw()
		until selectButton.justPressed
		
		changeTransparency(model_1, 1.0)
		xform_save_1:postMult(device.matrix)  -- save current position by updating the xform_save transform
		xform1:setMatrix(osg.Matrixd.identity())   -- what was formerly xform_save_1 * xform1 is now stored in xform_save_1; and xform1 is identity
		changeTransparency(model_2, 0.2)
		xform_save_2:postMult(osg.Matrixd.inverse(device.matrix))   -- prevent new item from "jumping" by compensating for current position of cursor
		print("Part 2 is selected.")
		
		repeat
			xform2:setMatrix(device.matrix)
			--cursor_xform:setMatrix(device.matrix)
			Actions.waitForRedraw()
		until selectButton.justPressed
		
		changeTransparency(model_2, 1.0)
		xform_save_2:postMult(device.matrix)  -- save current position by updating the xform_save transform
		xform2:setMatrix(osg.Matrixd.identity())   -- what was formerly xform_save_2 * xform2 is now stored in xform_save_2; and xform2 is identity
		changeTransparency(model_3, 0.2)
		xform_save_3:postMult(osg.Matrixd.inverse(device.matrix))   -- prevent new item from "jumping" by compensating for current position of cursor
		print("Part 3 is selected.")
		
		repeat
			xform3:setMatrix(device.matrix)
			--cursor_xform:setMatrix(device.matrix)
			Actions.waitForRedraw()
		until selectButton.justPressed
		
		changeTransparency(model_3, 1.0)
		xform_save_3:postMult(device.matrix)  -- save current position by updating the xform_save transform
		xform3:setMatrix(osg.Matrixd.identity())   -- what was formerly xform_save_3 * xform3 is now stored in xform_save_3; and xform3 is identity
		changeTransparency(model_4, 0.2)
		xform_save_4:postMult(osg.Matrixd.inverse(device.matrix))   -- prevent new item from "jumping" by compensating for current position of cursor
		print("Part 4 is selected.")
		
		repeat
			xform4:setMatrix(device.matrix)
			--cursor_xform:setMatrix(device.matrix)
			Actions.waitForRedraw()
		until selectButton.justPressed
		
	end
end)