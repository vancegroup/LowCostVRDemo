require("getScriptFilename")
vrjLua.appendToModelSearchPath(getScriptFilename())
device = gadget.PositionInterface("VJWand")
model_1 = Model("OSG/wiimote.ive")
display = osg.DisplaySettings()
print([[screen width]], display:getScreenWidth())
print([[height]], display:getScreenHeight())
print([[distance]], display:getScreenDistance())

xform1 = osg.AutoTransform()
xform1:setPosition(Vec(-3.1, 2.85, 0.0))
xform1:setAutoRotateMode(1)
xform1:setAutoScaleToScreen(0)
xform1:addChild(model_1)
RelativeTo.Room:addChild(xform1)

--[[
xform1 = Transform{
	position = {-1,2,0},
	orientation = AngleAxis(Degrees(0), Axis{0.0, 1.0, 0.0})}
RelativeTo.Room:addChild(xform1)
xform1:addChild(model_1)
]]
--[[xform1 = Transform{
	position = {0,1.3,0},
	orientation = AngleAxis(Degrees(7), Axis{0.0, 1.0, 0.0})}
xform2 = Transform{
	orientation = AngleAxis(Degrees(-5), Axis{1.0, 0.0, 0.0})}
RelativeTo.Room:addChild(xform2)

xform2:addChild(xform1)
xform1:addChild(model_1)]]

-- [[ How are you going to adjust for different screen sizes??]]