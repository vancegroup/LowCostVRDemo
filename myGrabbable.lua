require "myTransparentGroup"

local gettransgroup = {}    -- table which maps a Grabbable to its transgroup
local getxform = {}   -- table which maps a Grabbable to its xform
local getxform_save = {}    -- table which maps a Grabbable to its xform_save
local getdevice = {}   -- table which maps a Grabbable to its wand 
local getframeaction = {}    -- table which maps a Grabbable to its FrameAction (if it is currently grabbed)

function myGrabbable(someNode, wand)    -- accepts a Geode or Transform etc.; returns a Grabbable based on it
	local transgroup = myTransparentGroup{ alpha = 1.0, someNode }
	local xform = osg.MatrixTransform()
	xform:addChild(transgroup)
	local xform_save = osg.MatrixTransform(osg.Matrixd.identity())   -- identity() is a static method for the osg.Matrixd class.
	xform_save:addChild(xform)
	
	local grabbable = xform_save   -- the xform_save is the outermost node that will be returned
	gettransgroup[grabbable] = transgroup
	getxform[grabbable] = xform
	getxform_save[grabbable] = xform_save
	getdevice[grabbable] = wand
	
	return grabbable
end

function grab(grabbable)
	getxform_save[grabbable]:postMult(osg.Matrixd.inverse(getdevice[grabbable].matrix))   -- prevent new item from "jumping" by compensating for current position of cursor
	changeTransparency(gettransgroup[grabbable], 0.2)
	getframeaction[grabbable] = Actions.addFrameAction(function() 
		while true do
		getxform[grabbable]:setMatrix(getdevice[grabbable].matrix)
		Actions.waitForRedraw()
		end
	end)
end

function ungrab(grabbable)
	Actions.removeFrameAction(getframeaction[grabbable])
	changeTransparency(gettransgroup[grabbable], 1.0)
	getxform_save[grabbable]:postMult(getdevice[grabbable].matrix)   -- save current position by updating the xform_save transform
	getxform[grabbable]:setMatrix(osg.Matrixd.identity())   -- what was formerly xform_save * xform is now stored in xform_save; xform is now identity
end