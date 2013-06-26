require "myTransparentGroup"

--[[
    class myGrabbable = {}
        Constructor: myGrabbable(someNode, wand)  -- accepts a Geode or Transform etc.; returns a Grabbable based on it
        
        .attach_here   -- since I don't know how to properly inherit from Transform or Node (which myGrabbable should be a subclass of), instead we have this
                       -- .attach_here field. When you have a grabbable, the grabbable.attach_here is what you should add as a child of a Transform or RelativeTo.World etc.
        
        -- private members
        .transgroup  -- a myTransparentGroup
        .xform_track  -- an osg.MatrixTransform
        .xform_save  -- also an osg.MatrixTransform
        .wand      -- a gadget.PositionInterface
        .frameaction  -- the handle to its FrameAction (see Actions.lua) if it is currently grabbed
]]--

function myGrabbable(someNode, wand)    
	grabbable = {}
    grabbable.transgroup = myTransparentGroup{ alpha = 1.0, someNode }
	grabbable.xform_track = osg.MatrixTransform()
	grabbable.xform_track:addChild(grabbable.transgroup)
	grabbable.xform_save = osg.MatrixTransform(osg.Matrixd.identity())   -- identity() is a static method for the osg.Matrixd class.
	grabbable.xform_save:addChild(grabbable.xform_track)
	grabbable.wand = wand
    grabbable.attach_here = grabbable.xform_save   -- the outermost node. See above outline for a good description of this field.
	
	return grabbable
end

function grab(grabbable)
	grabbable.xform_save:preMult(osg.Matrixd.inverse(grabbable.wand.matrix))   -- prevent new item from "jumping" by compensating for current position of cursor
	changeTransparency(grabbable.transgroup, 0.2)
	grabbable.frameaction = Actions.addFrameAction(function() 
		while true do
			grabbable.xform_track:setMatrix(grabbable.wand.matrix)
			Actions.waitForRedraw()
		end
	end)
end

function ungrab(grabbable)
	Actions.removeFrameAction(grabbable.frameaction)
	changeTransparency(grabbable.transgroup, 1.0)
	grabbable.xform_save:preMult(grabbable.wand.matrix)   -- save current position by updating the xform_save transform
	grabbable.xform_track:setMatrix(osg.Matrixd.identity())   -- what was formerly xform_save * xform_track is now stored in xform_save; xform_track is now identity
end