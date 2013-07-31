require "myTransparentGroup"
require "cursor"

--[[
    class myGrabbable = {}
        Constructor: myGrabbable(someNode)  -- accepts a Geode or Transform etc.; returns a Grabbable based on it.
        
        Public members:
        .attach_here   -- since I don't know how to properly inherit from Transform or Node (which myGrabbable should be a subclass of), instead we have this
                       -- .attach_here field. When you have a grabbable, the grabbable.attach_here is what you should add as a child of a Transform or World etc.
        
        Matrixd :getWorldToLocalCoords()  -- returns a matrix to convert a point from world coordinates to the local coordinate system of the Node the Grabbable was based on
        Matrixd :getLocalToWorldCoords()  -- same, but a matrix to convert from local coordinates to the world coordinates
        Matrixd :getCursorPoseInLocalCoords()  -- position and rotation of the cursor seen from the current viewpoint
        void :makeTransparent()
        void :makeSemiTransparent()
        void :makeUnTransparent()
        (Lua)bool .grabbed   -- whether the object is currently grabbed
        
        Private members:
        .transgroup  -- a myTransparentGroup
        .xform_track  -- an osg.MatrixTransform
        .xform_save  -- also an osg.MatrixTransform
        .frameaction  -- the handle to its FrameAction (see Actions.lua) if it is currently grabbed
]]--

function myGrabbable(someNode)    
    local grabbable = {}
    grabbable.transgroup = myTransparentGroup{ alpha = 1.0, someNode }
    grabbable.xform_track = MatrixTransform{ grabbable.transgroup }
    grabbable.xform_save = MatrixTransform{ grabbable.xform_track }
    grabbable.attach_here = grabbable.xform_save   -- the outermost node. See above outline for a good description of this field.
    
    grabbable.getLocalToWorldCoords = function()
        return someNode:getWorldMatrices().Item[1]
    end
    
    grabbable.getWorldToLocalCoords = function()
        return osg.Matrixd.inverse(grabbable.getLocalToWorldCoords())
    end
    
    grabbable.getCursorPoseInLocalCoords = function()
        return cursor:getPose() * osg.Matrixd.inverse(grabbable.xform_save:getWorldMatrices().Item[1])    -- using the new * for matrix multiplication in JuggLua
    end
    
    grabbable.makeTransparent = function()
        changeTransparency(grabbable.transgroup, 0.5)
    end
    
    grabbable.makeSemiTransparent = function()
        changeTransparency(grabbable.transgroup, 0.7)
    end
    
    grabbable.makeUnTransparent = function()
        changeTransparency(grabbable.transgroup, 1.0)
    end
    
    grabbable.grabbed = false
    
    return grabbable
end

function grab(grabbable)   -- this function (and ungrab) are safe to call regardless of whether the object is currently grabbed or not.
    if not grabbable.grabbed then
        grabbable.grabbed = true
        grabbable:makeTransparent()
        grabbable.xform_save:preMult(osg.Matrixd.inverse(grabbable:getCursorPoseInLocalCoords()))   -- prevent new item from "jumping" by compensating for current position of cursor
        grabbable.xform_track:setMatrix(grabbable:getCursorPoseInLocalCoords())  -- have to do this right here, not just rely on the following FrameAction, or this frame the object will appear to 'jump' out of place, before returning to correct one frame later when the FrameAction kicks in. That one frame jump is actually noticeable to the user.
        grabbable.frameaction = Actions.addFrameAction(function() 
            while true do
                grabbable.xform_track:setMatrix(grabbable:getCursorPoseInLocalCoords())
                Actions.waitForRedraw()
            end
        end)
    end
end

function ungrab(grabbable)
    if grabbable.grabbed then
        grabbable.grabbed = false
        Actions.removeFrameAction(grabbable.frameaction)
        grabbable:makeUnTransparent()
        grabbable.xform_save:preMult(grabbable:getCursorPoseInLocalCoords())   -- save current position by updating the xform_save transform
        grabbable.xform_track:setMatrix(osg.Matrixd.identity())   -- what was formerly xform_save * xform_track is now stored in xform_save; xform_track is now identity
    end
end