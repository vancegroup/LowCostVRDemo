--require("getScriptFilename")
--require "controls"
require "myShapes"
require "myColor"
require "osgDB"
require "gldef"
require "myTransparentGroup"

--vrjLua.appendToModelSearchPath(getScriptFilename())

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

sphere = myShapes(smimage1, "sphere")
cube = myShapes(smimage2 , "cube")
pyramid = myShapes(smimage3, "pyramid")
cylinder = myShapes(smimage4, "cylinder")
cone = myShapes(smimage5, "cone")

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

menu = {shapeMenu, colorMenu}

-- set up position to draw menus
cmxform = Transform{
	position={0,0.43,-10},
	orientation=AngleAxis(Degrees(180), Axis{0.0,1.0,0.0}),
}
	
smxform = Transform{
	position={0,1.07,-10},
	orientation=AngleAxis(Degrees(180), Axis{0.0,1.0,0.0}),
}

-- makes the menus always display in screen coordinates
xform1 = osg.AutoTransform()
xform1:setAutoRotateMode(1)
xform1:setAutoScaleToScreen(0)
xform1:setPosition(Vec(0.5, 1.0, 0.0))

cmxform:addChild(cmimage1)
transpCM = myTransparentGroup({cmxform})
xform1:addChild(transpCM)

smxform:addChild(smimage1)
transpSM = myTransparentGroup({smxform})
xform1:addChild(transpSM)

-- initialize to 1 and 1 automatically
colorIndex = 1
shapeIndex = 1
libraryPressed = 1

--[[
Actions.addFrameAction(function()
	while true do
		if libraryPressed == 1 then 
			if open_library_button.justPressed then
				RelativeTo.Room:addChild(xform1)
				libraryPressed = 0
				activeMenu = 1
				changeTransparency(transpCM, 0.5)
			end
		else
]]--
function libraryCalled()
	RelativeTo.Room:addChild(xform1)
	activeMenu = 1
	changeTransparency(transpCM, 0.5)
    while true do
        if open_library_button.justPressed then
            RelativeTo.Room:removeChild(xform1)
            print("colorIndex", colorIndex)
            print("shapeIndex", shapeIndex)
            libraryPressed = 1
        elseif library_switch_up_button.justPressed or library_switch_down_button.justPressed then
            if activeMenu == 2 then
                activeMenu = 1
                changeTransparency(transpCM, 0.5)
                changeTransparency(transpSM, 1.0)
                print("switching to shapes")
            else
                activeMenu = 2
                changeTransparency(transpCM, 1.0)
                changeTransparency(transpSM, 0.5)
                print("switching to color")
            end
        elseif library_scroll_left_button.justPressed then
            if activeMenu == 1 then 
                print("moving left one shape")
                if shapeIndex > 1 and shapeIndex <= 5 then
                    shapeIndex = shapeIndex - 1
                    smxform:replaceChild(shapeMenu[shapeIndex + 1].image, shapeMenu[shapeIndex].image)
                end
            else 			
                print("moving left one color")
                if colorIndex > 1 and colorIndex <= 9 then
                    colorIndex = colorIndex - 1
                    cmxform:replaceChild(colorMenu[colorIndex+1].image, colorMenu[colorIndex].image)
                end			
            end
        elseif library_scroll_right_button.justPressed then
            if activeMenu == 1 then
                print ("changing shape to the right")
                if shapeIndex >= 1 and shapeIndex < 5 then
                    shapeIndex = shapeIndex + 1
                    smxform:replaceChild(shapeMenu[shapeIndex - 1].image, shapeMenu[shapeIndex].image)
                end
            else
                print("changing color to the right")
                if colorIndex >= 1 and colorIndex < 9 then
                    colorIndex = colorIndex + 1
                    cmxform:replaceChild(colorMenu[colorIndex-1].image, colorMenu[colorIndex].image)
                end
            end
        elseif library_confirm_button.justPressed then
            return shapeMenu[shapeIndex].name, colorMenu[colorIndex].vec
        end
        Actions.waitForRedraw()
	end
end

-- [[ How are you going to adjust for different screen sizes??]]