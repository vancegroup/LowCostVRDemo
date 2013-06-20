require "TransparentGroup"

local mystate  -- right now there's only 1 mystate for all models, that is a problem

-- modified copy of the lua src for the TransparentGroup{} function
function myTransparentGroup(arg)
	local group = osg.Group()
	-- Add all passed nodes to the group to make transparent
	for _, node in ipairs(arg) do
		group:addChild(node)
	end
	mystate = group:getOrCreateStateSet()
	mystate:setRenderingHint(2) -- transparent bin

	local CONSTANT_ALPHA = 0x8003
	local ONE_MINUS_CONSTANT_ALPHA = 0x8004
	local bf = osg.BlendFunc()
	bf:setFunction(CONSTANT_ALPHA, ONE_MINUS_CONSTANT_ALPHA)
	mystate:setAttributeAndModes(bf)

	local bc = osg.BlendColor(osg.Vec4(1.0, 1.0, 1.0, arg.alpha or 0.5))
	mystate:setAttributeAndModes(bc)
	group:setStateSet(mystate)
	return group
end

function changeTransparency(my_trans_group, new_alpha)
	local bc = osg.BlendColor(Vecf(1.0, 1.0, 1.0, new_alpha))
	mystate:setAttributeAndModes(bc)
end

device = gadget.PositionInterface("VJWand")

model_1 = myTransparentGroup{ alpha = 1.0, Model("sparta_models/Clutch-FlywheelPart1.ive") }
model_2 = myTransparentGroup{ alpha = 1.0, Model("sparta_models/Clutch-FlywheelPart2.ive") }
model_3 = myTransparentGroup{ alpha = 1.0, Model("sparta_models/Clutch-FlywheelPart3.ive") }
model_4 = myTransparentGroup{ alpha = 1.0, Model("sparta_models/Clutch-FlywheelPart4.ive") }
cursor_geode = osg.Geode()
cursor_geode:addDrawable(osg.ShapeDrawable(osg.Cone(Vecf(0,0,0), 0.1, 0.3)))

xform1 = osg.MatrixTransform()
xform2 = osg.MatrixTransform()
xform3 = osg.MatrixTransform()
xform4 = osg.MatrixTransform()
cursor_xform = osg.MatrixTransform()

xform1:addChild(model_1)
xform2:addChild(model_2)
xform3:addChild(model_3)
xform4:addChild(model_4)
cursor_xform:addChild(cursor_geode)

RelativeTo.World:addChild(xform1)
RelativeTo.World:addChild(xform2)
RelativeTo.World:addChild(xform3)
RelativeTo.World:addChild(xform4)
RelativeTo.World:addChild(cursor_xform)

Actions.addFrameAction(function()
	while true do
		--xform1:setMatrix(device.matrix)
		--xform2:setMatrix(device.matrix)
		--xform3:setMatrix(device.matrix)
		--xform4:setMatrix(device.matrix)
		--cursor_xform:setMatrix(device.matrix)
		changeTransparency(model_1, 0.2)
		Actions.waitForRedraw()
	end
end)