require("osgFX")

function makeShape(color)
	thing = osg.Box(Vecf(0.5, 0.5, 0.5), 0.1, 0.5, 0.3)
	shapeDrawable = osg.ShapeDrawable(thing)
	--shapeDrawable:setColor(color)
	cubeGeode = osg.Geode()
	cubeGeode:addDrawable(shapeDrawable)
	xform = Transform{ position = {1.0, 2.0, 0.0}} 
	xform:addChild(cubeGeode)
	return xform
end
xform = makeShape(osg.Vec4f(1.0, 0.4, 0.7, 1.0))

local GraphicsNode = osgFX.Scribe()
GraphicsNode:setWireframeLineWidth(5.0)
GraphicsNode:addChild(xform)
--local GraphicsSwitch = osg.Switch()
--GraphicsSwitch:addChild(GraphicsNode)
--RelativeTo.World:addChild(GraphicsSwitch)
RelativeTo.World:addChild(GraphicsNode)

--[[
mystate = xform:getOrCreateStateSet()
wireframeMode = osg.PolygonMode()
wireframeMode:setMode(0, 2)
mystate:setAttributeAndModes(wireframeMode)
xform:setState(mystate)
RelativeTo.World(xform)
]]