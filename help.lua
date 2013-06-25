require("getScriptFilename")
vrjLua.appendToModelSearchPath(getScriptFilename())
device = gadget.PositionInterface("VJWand")
libraryButton = gadget.DigitalInterface("VJButton1")

model_1 = Model("OSG/wiimote.ive")
model_2 = Model("OSG/wiimote.ive")

--[[display = osg.DisplaySettings()
print("screen width", display:getScreenWidth())
print("height", display:getScreenHeight())
print("distance", display:getScreenDistance())
]]

xform1 = osg.AutoTransform()
xform1:setPosition(Vec(-3.1, 2.85, 0.0))
xform1:setAutoRotateMode(1)
xform1:setAutoScaleToScreen(0)
xform1:addChild(model_1)

xform2 = osg.AutoTransform()
xform2:setPosition(Vec(-1.8, 2.85, 0.0))
xform2:setAutoRotateMode(1)
xform2:setAutoScaleToScreen(0)
xform2:addChild(model_2)

Actions.addFrameAction(function()
	while true do
		repeat
			Actions.waitForRedraw()
		until libraryButton.justPressed
		
		RelativeTo.Room:addChild(xform1)
		RelativeTo.Room:addChild(xform2)
		repeat
			Actions.waitForRedraw()
		until libraryButton.justPressed
			RelativeTo.Room:removeChild(xform1)
			RelativeTo.Room:removeChild(xform2)
	end
end)

-- [[ How are you going to adjust for different screen sizes??]]