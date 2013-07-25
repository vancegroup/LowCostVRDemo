require "myTransparentGroup"
require "cursor"

--[[
    class myGrabbable = {}
        Constructor: myGrabbable(someNode, [invertDrag], [forceAlwaysOpaque])  -- accepts a Geode or Transform etc. (someNode); returns a Grabbable based on it. Optional parameter invertDrag, if true, inverts the handling of the object. See the .invert flag below. Similarly, optional parameter forceAlwaysOpaque, if true, turns off the normal behavior of making grabbed objects somewhat transparent.
        
        Public members:
        .attach_here   -- since I don't know how to properly inherit from Transform or Node (which myGrabbable should be a subclass of), instead we have this
                       -- .attach_here field. When you have a grabbable, the grabbable.attach_here is what you should add as a child of a Transform or World etc.
        
        Matrixd :getWorldToLocalCoords()  -- returns a matrix to convert a point from world coordinates to the local coordinate system of the Node the Grabbable was based on
        Matrixd :getLocalToWorldCoords()  -- same, but a matrix to convert from local coordinates to the world coordinates
        void :makeTransparent()
        void :makeSemiTransparent()
        void :makeUnTransparent()
        (Lua)bool .grabbed   -- whether the object is currently grabbed
        
        Private members:
        .transgroup  -- a myTransparentGroup
        .xform_track  -- an osg.MatrixTransform
        .xform_save  -- also an osg.MatrixTransform
        .frameaction  -- the handle to its FrameAction (see Actions.lua) if it is currently grabbed
        .invert  -- inverts all the controls affecting this grabbable. So, the grabbable moves the opposite direction of the wand when grabbed, rotates the opposite direction etc. Best suited for use when grabbing the world - then it appears to grab the 'camera' instead.
        :getWandMatrix()   -- gets cursor.getWandMatrix() and either inverts it or not based on grabbable.invert
        .forceOpaque  -- if true, grabbable will not be made somewhat transparent when grabbed. See discussion of the constructor parameter forceAlwaysOpaque, which controls this flag.
]]--

function myGrabbable(someNode, invertDrag, forceAlwaysOpaque)    
    local grabbable = {}
    grabbable.transgroup = myTransparentGroup{ alpha = 1.0, someNode }
    grabbable.xform_track = osg.MatrixTransform()
    grabbable.xform_track:addChild(grabbable.transgroup)
    grabbable.xform_save = osg.MatrixTransform(osg.Matrixd.identity())   -- identity() is a static method for the osg.Matrixd class.
    grabbable.xform_save:addChild(grabbable.xform_track)
    grabbable.attach_here = grabbable.xform_save   -- the outermost node. See above outline for a good description of this field.
    
    grabbable.getLocalToWorldCoords = function()
        return someNode:getWorldMatrices(RelativeTo.World).Item[1]
    end
    grabbable.getWorldToLocalCoords = function()
        return osg.Matrixd.inverse(grabbable.getLocalToWorldCoords())
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
    
    grabbable.invert = invertDrag
    grabbable.getWandMatrix = function()
        if grabbable.invert then
            return osg.Matrixd.inverse(cursor:getWandMatrix())
        else
            return cursor:getWandMatrix()
        end
    end
    
    grabbable.forceOpaque = forceAlwaysOpaque
    
    grabbable.grabbed = false
    
    return grabbable
end

function grab(grabbable)   -- this function (and ungrab) are safe to call regardless of whether the object is currently grabbed or not.
    if not grabbable.grabbed then
        grabbable.grabbed = true
        if not grabbable.forceOpaque then grabbable:makeTransparent() end
        grabbable.xform_save:preMult(osg.Matrixd.inverse(grabbable.getWandMatrix()))   -- prevent new item from "jumping" by compensating for current position of cursor
        grabbable.frameaction = Actions.addFrameAction(function() 
            while true do
                grabbable.xform_track:setMatrix(grabbable.getWandMatrix())
                Actions.waitForRedraw()
            end
        end)
    end
end

function ungrab(grabbable)
    if grabbable.grabbed then
        grabbable.grabbed = false
        Actions.removeFrameAction(grabbable.frameaction)
        if not grabbable.forceOpaque then grabbable:makeUnTransparent() end
        grabbable.xform_save:preMult(grabbable.getWandMatrix())   -- save current position by updating the xform_save transform
        grabbable.xform_track:setMatrix(osg.Matrixd.identity())   -- what was formerly xform_save * xform_track is now stored in xform_save; xform_track is now identity
    end
end