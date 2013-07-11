local wfstate = {}   -- a StateSet for each group that has been initialized with the myTransparentGroup function. The keys for the table are the groups themselves, the values are the StateSets.

function myWireFrameGroup(arg)
	local group = osg.Group()
	-- Add all passed nodes to the group to make transparent
	for _, node in ipairs(arg) do
		group:addChild(node)
	end
	--grab state set of the node, create StateSet if one does not exist
	mystate = group:getOrCreateStateSet()
	
	-- creates wireframe mode and overrides attribute of StateSet
	local wireframeMode = osg.PolygonMode()
	wireframeMode:setMode(1, 2)

	--wireframeMode = osg.PolygonMode:setMode(osg.PolygonMode.FRONT_AND_BACK, osg.PolygonMode.LINE)
	--mystate:setAttributeAndModes(wireframeMode, osg.StateAttribute.OVERRIDE or osg.StateAttribute.ON)
	--mystate:setAttributeAndModes(wireframeMode)
	polygonMode = osg.PolygonMode()
	polygonMode:setMode(1, 3)
	
	mystate:setAttributeAndModes(wireframeMode)
	group:setStateSet(mystate)
	wfstate[group] = mystate
	return group
end

function turnOffWireFrame(my_wf_group)
	local polygonMode = osg.PolygonMode()
	polygonMode:setMode(1, 3)
	wfstate[my_wf_group]:setAttributeAndModes(polygonMode, 2)
end

function turnOnWireFrame(my_wf_group)
	local wireframeMode = osg.PolygonMode()
	wireframeMode:setMode(1, 2)
	wfstate[my_wf_group]:setAttributeAndModes(wireframeMode, 2)
end
