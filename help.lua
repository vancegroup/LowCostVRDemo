require("getScriptFilename")
require "controls"
require "myShapes"
require "myColor"
require "osgDB"
require "gldef"

vrjLua.appendToModelSearchPath(getScriptFilename())
libraryButton = gadget.DigitalInterface('VJButton1')

function createImageObject(arg)
	local scale = arg.scale or 1
	local width = (arg.width/72)*0.0254*scale
	local height = (arg.height/72)*0.0254*scale
	local chart = osg.Geode()
	chart:addDrawable(osg.ShapeDrawable(osg.Box()))

	local texture = osg.Texture2D()
	local img = Model(arg.img)
	texture:setImage(img)

	local ss = chart:getOrCreateStateSet()
	ss:setTextureAttributeAndModes(0, texture, osg.StateAttribute.Values.ON);

	local xform = Transform{chart}
	xform:setScale(Vec(width,height,.005))
	return xform
end


function makeShape(color)
	thing = osg.Box(Vecf(0.5, 0.5, 0.5), 0.1, 0.5, 0.3)
	shapeDrawable = osg.ShapeDrawable(thing)
	shapeDrawable:setColor(color)
	cubeGeode = osg.Geode()
	cubeGeode:addDrawable(shapeDrawable)
	xform = Transform{ position = {1.0, 2.0, 0.0}} 
	xform:addChild(cubeGeode)
	return xform
end

--find path to local image file
local smImgPath1 = vrjLua.findInModelSearchPath([[OSG/sm1.jpg]])
local smImgPath2 = vrjLua.findInModelSearchPath([[OSG/sm2.jpg]])
local smImgPath3 = vrjLua.findInModelSearchPath([[OSG/sm3.jpg]])
local smImgPath4 = vrjLua.findInModelSearchPath([[OSG/sm4.jpg]])
local smImgPath5 = vrjLua.findInModelSearchPath([[OSG/sm5.jpg]])

local cmImgPath1 = vrjLua.findInModelSearchPath([[OSG/cm1.jpg]])
local cmImgPath2 = vrjLua.findInModelSearchPath([[OSG/cm2.jpg]])
local cmImgPath3 = vrjLua.findInModelSearchPath([[OSG/cm3.jpg]])
local cmImgPath4 = vrjLua.findInModelSearchPath([[OSG/cm4.jpg]])
local cmImgPath5 = vrjLua.findInModelSearchPath([[OSG/cm5.jpg]])
local cmImgPath6 = vrjLua.findInModelSearchPath([[OSG/cm6.jpg]])
local cmImgPath7 = vrjLua.findInModelSearchPath([[OSG/cm7.jpg]])
local cmImgPath8 = vrjLua.findInModelSearchPath([[OSG/cm8.jpg]])
local cmImgPath9 = vrjLua.findInModelSearchPath([[OSG/cm9.jpg]])

--create "image object" by passing width (pixels), height (in pixels), and path to image (optional: scale)
smimage1 = createImageObject({width=1820,height=420,img=smImgPath1, scale = 5})
smimage2 = createImageObject({width=1820,height=420,img=smImgPath2, scale = 5})
smimage3 = createImageObject({width=1820,height=420,img=smImgPath3, scale = 5})
smimage4 = createImageObject({width=1820,height=420,img=smImgPath4, scale = 5})
smimage5 = createImageObject({width=1820,height=420,img=smImgPath5, scale = 5})

cmimage1 = createImageObject({width = 1820, height =250, img = cmImgPath1, scale = 5})
cmimage2 = createImageObject({width = 1820, height =250, img = cmImgPath2, scale = 5})
cmimage3 = createImageObject({width = 1820, height =250, img = cmImgPath3, scale = 5})
cmimage4 = createImageObject({width = 1820, height =250, img = cmImgPath4, scale = 5})
cmimage5 = createImageObject({width = 1820, height =250, img = cmImgPath5, scale = 5})
cmimage6 = createImageObject({width = 1820, height =250, img = cmImgPath6, scale = 5})
cmimage7 = createImageObject({width = 1820, height =250, img = cmImgPath7, scale = 5})
cmimage8 = createImageObject({width = 1820, height =250, img = cmImgPath8, scale = 5})
cmimage9 = createImageObject({width = 1820, height =250, img = cmImgPath9, scale = 5})

sphere = myShapes(smimage1, device, 0)
cube = myShapes(smimage2 , device, 1)
pyramid = myShapes(smimage3, device, 2)
cylinder = myShapes(smimage4, device, 3)
cone = myShapes(smimage5, device, 4)

shapeMenu = {sphere, cube, pyramid, cylinder, cone}

red = myColor(cmimage1, osg.Vec4f(1.0, 0.0, 0.0, 0.0), "red")
orange = myColor(cmimage2, osg.Vec4f(1.0, 0.5, 0.0, 0.0), "orange")
yellow = myColor(cmimage3, osg.Vec4f(1.0, 1.0, 0.0, 0.0), "yellow")
green = myColor(cmimage4, osg.Vec4f(0.0, 1.0, 0.0, 0.0), "green")
blue = myColor(cmimage5, osg.Vec4f(0.0, 0.0, 1.0, 0.0), "blue")
purple = myColor(cmimage6, osg.Vec4f(0.5, 0.0, 0.5, 0.0), "purple")
pink = myColor(cmimage7, osg.Vec4f(1.0, 0.4, 0.7, 0.0), "pink")
brown = myColor(cmimage8, osg.Vec4f(0.46, 0.27, 0.074, 0.0), "brown")
gray = myColor(cmimage9, osg.Vec4f(0.5, 0.5, 0.5, 0.0), "gray")

colorMenu = {red, orange, yellow, green, blue, purple, pink, brown, gray}

-- initialize to 1 and 1 automatically
colorIndex = 1
shapeIndex = 1
-- returns shape, color

menu = {shapeMenu, colorMenu}

-- set up position to draw menus
cmxform = Transform{
	position={0,0.43,0},
	orientation=AngleAxis(Degrees(180), Axis{0.0,1.0,0.0}),
}
	
smxform = Transform{
	position={0,1.07,0},
	orientation=AngleAxis(Degrees(180), Axis{0.0,1.0,0.0}),
}

-- makes the menus always display in screen coordinates
xform1 = osg.AutoTransform()
xform1:setAutoRotateMode(1)
xform1:setAutoScaleToScreen(0)
xform1:setPosition(Vec(0.5, 1.0, 0.0))

cmxform:addChild(cmimage1)
xform1:addChild(cmxform)

smxform:addChild(smimage1)
xform1:addChild(smxform)

RelativeTo.Room:addChild(xform1)


--lala = makeShape(colorMenu[4].vec)
--RelativeTo.World:addChild(lala)


--RelativeTo.Room:addChild(xform1)
--RelativeTo.Room:addChild(xform2)
Actions.addFrameAction(function()
	while true do
		--[[
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
		]]
		--[[
		repeat
			Actions.waitForRedraw()
		until libraryButton.justPressed
			RelativeTo.Room:addChild(xform1)
		]]
		repeat 
			Actions.waitForRedraw()
		until somethingHappens()
		
		if hold_to_adjust_view_button.justPressed then
			if colorIndex > 1 and colorIndex <= 9 then
				colorIndex = colorIndex - 1
				cmxform:replaceChild(colorMenu[colorIndex+1].image, colorMenu[colorIndex].image)
			else 
				colorIndex = 1
			end
			print(colorIndex)
		
		elseif click_to_duplicate_button.justPressed then
			if colorIndex >= 1 and colorIndex < 9 then
				colorIndex = colorIndex + 1
				cmxform:replaceChild(colorMenu[colorIndex-1].image, colorMenu[colorIndex].image)

			else
				colorIndex = 9
				xform = makeShape(colorMenu[colorIndex].vec)
			end
			print(colorIndex)
		--[[
		elseif libraryButton.justPressed then
			RelativeTo.Room:removeChild(xform1)]]
		end
	end
end)

function somethingHappens()
    for _, b in ipairs(allbuttons) do
        if b.pressed then return b end
    end
    return nil
end

-- [[ How are you going to adjust for different screen sizes??]]