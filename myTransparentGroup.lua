local alphastates = {}   -- a StateSet for each group that has been initialized with the myTransparentGroup function. The keys for the table are the groups themselves, the values are the StateSets.

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
--	mystate:setAttributeAndModes(bc)
	group:setStateSet(mystate)
	alphastates[group] = mystate
	return group
end

function changeTransparency(my_trans_group, new_alpha)
	local bc = osg.BlendColor(Vecf(1.0, 1.0, 1.0, new_alpha))
	alphastates[my_trans_group]:setAttributeAndModes(bc)
end