require("getScriptFilename")
require "myShapes"
require "myColor"

vrjLua.appendToModelSearchPath(getScriptFilename())
device = gadget.PositionInterface("VJWand")
libraryButton = gadget.DigitalInterface("VJButton1")

sphere = myShapes(Model("OSG/wiimote.ive"), device, 0)
cube = myShapes(Model("OSG/wiimote.ive") , device, 1)
pyramid = myShapes(Model("OSG/wiimote.ive"), device, 2)
cylinder = myShapes(Model("OSG/wiimote.ive"), device, 3)
cone = myShapes(Model("OSG/wiimote.ive"), device, 4)

shapeMenu = {sphere, cube, pyramid, cylinder, cone}

red = myColor(Model("OSG/wiimote.ive"), osg.Vec4f(1.0, 0.0, 0.0, 0.0), "red")
orange = myColor(Model("OSG/wiimote.ive"), osg.Vec4f(1.0, 0.5, 0.0, 0.0), "orange")
yellow = myColor(Model("OSG/wiimote.ive"), osg.Vec4f(1.0, 1.0, 0.0, 0.0), "yellow")
green = myColor(Model("OSG/wiimote.ive"), osg.Vec4f(0.0, 1.0, 0.0, 0.0), "green")
blue = myColor(Model("OSG/wiimote.ive"), osg.Vec4f(0.0, 0.0, 1.0, 0.0), "blue")
purple = myColor(Model("OSG/wiimote.ive"), osg.Vec4f(0.5, 0.0, 0.5, 0.0), "purple")
pink = myColor(Model("OSG/wiimote.ive"), osg.Vec4f(1.0, 0.4, 0.7, 0.0), "pink")
brown = myColor(Model("OSG/wiimote.ive"), osg.Vec4f(0.46, 0.27, 0.074, 0.0), "brown")
gray = myColor(Model("OSG/wiimote.ive"), osg.Vec4f(0.5, 0.5, 0.5, 0.0), "gray")
colorMenu = {red, orange, yellow, green, blue, purple, pink, brown, gray}
menu = {shapeMenu, colorMenu}
print(menu[1][3].pos)

thing = osg.Box(Vecf(0.5, 0.5, 0.5), 0.1, 0.5, 0.3)
shapeDrawable = osg.ShapeDrawable(thing)
shapeDrawable:setColor(colorMenu[1].vec)
cubeGeode = osg.Geode()
cubeGeode:addDrawable(shapeDrawable)
local xform = osg.MatrixTransform()
xform:addChild(cubeGeode)
RelativeTo.World:addChild(xform)

function setUp(shape)
	xform1 = osg.AutoTransform()
	xform1:setAutoRotateMode(1)
	xform1:setAutoScaleToScreen(0)
	xform1:setPosition(Vec(-3.1, 2.85, 0.0))
	xform1:addChild(model_1)
end

function selectLeft()
	
end

model_1 = Model("OSG/wiimote.ive")
model_2 = Model("OSG/balloon.ive")
--[[display = osg.DisplaySettings()
print("screen width", display:getScreenWidth())
print("height", display:getScreenHeight())
print("distance", display:getScreenDistance())
]]

xform1 = osg.AutoTransform()
xform1:setAutoRotateMode(1)
xform1:setAutoScaleToScreen(0)
xform1:setPosition(Vec(-3.1, 2.85, 0.0))
xform1:addChild(model_1)

xform2 = osg.AutoTransform()
xform2:setAutoRotateMode(1)
xform2:setAutoScaleToScreen(0)
xform2:setPosition(Vec(-1.8, 2.85, 0.0))
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