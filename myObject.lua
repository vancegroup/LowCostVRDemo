require "myGrabbable"

--[[
    abstract base class myObject: inherits from myGrabbable
        Constructor: myObject(grabbable)   -- pass the Grabbable which this object will be based on
        
        (Lua)bool .selected   -- whether object is selected or not (a Lua bool not an osg bool)
        (Lua)bool .cursorOver   -- whether the cursor is over the object or not
        void :select()  -- select the object. Safe to call regardless of whether the object is currently selected or not.
        void :deselect()  -- deselect the object. Safe to call regardless of whether the object is currently selected or not.
        abstract Vec3f :getCenterInWorldCoords()  -- abstract methods are not implemented here and must be implemented by subclasses
        abstract void :initializeScaling()  -- get ready for subsequent calls to scale()
        abstract void :scale(float)
        abstract (Lua)bool :contains(Vec3f)   -- whether the object contains the point passed as argument
        abstract void :setColor(Vec4f)
        abstract Vec4f :getColor()
        abstract void :openForEditing()
        abstract void :closeForEditing()
        abstract void :removeObject()  -- removes the object from the environment
        
        Protected members:
        void :setCenter(Vec3d)  -- for moving the object's center without moving its local center. Using this function is necessary so that the object rotates around its local center and to prevent other undesirable effects
        void :getCenterDisplacement()   -- for getting the displacement that was set using :setCenter()
        Vec3f :getCursorPositionInConstructionCoords()   -- for use only during the object's construction
        
        Private members:
        .xform_centering  -- a PositionAttitudeTransform, which is responsible for moving the object's center (other than movement due to being grabbed, which is handled by the myGrabbable underlying the myObject) such that its local center can remain at local (0,0,0)
]]--

function myObject(grabbable)
    local object = grabbable
    object.xform_centering = Transform{   -- this explained above in the class description
        position = {0,0,0},
        object.attach_here
    }
    object.attach_here = Transform{ object.xform_centering }  -- attach_here is now a new wrapper for the whole myObject, i.e. the outermost node in the construct
    
    object.selected = false
    object.cursorOver = false
    
    object.select = function()
        object.selected = true
        grab(object)
    end
    
    object.deselect = function()
        object.selected = false
        ungrab(object)
    end
    
    object.setCenter = function(_, vec)
        object.xform_centering:setPosition(vec)
    end
    
    object.getCenterDisplacement = function()
        return object.xform_centering:getPosition()
    end
    
    object.getCursorPositionInConstructionCoords = function()
        local constructionToWorldMatrix = object.attach_here:getWorldMatrices().Item[1]
        local worldToConstructionMatrix = osg.Matrixd.inverse(constructionToWorldMatrix)
        return Vecf(worldToConstructionMatrix:preMult(cursor:getPosition()))
        -- identical to return Vecf(object:getWorldToLocalCoords():preMult(cursor:getPosition())) except that the construction-coords function is unaffected by calls to setCenter(). It's also unaffected by (doesn't account for) grabbing (selecting and moving/rotating), which is why it's only suitable for use during construction before it's been grabbed.
    end
    
    return object
end

-- a few other utility functions useful to various subclasses of myObject
function avgPosf(v1, v2)
    return Vecf( (v1:x()+v2:x())/2, (v1:y()+v2:y())/2, (v1:z()+v2:z())/2 )
end

function avgPosf_lock_y(v1, v2)
    return Vecf( (v1:x()+v2:x())/2, v1:y(), (v1:z()+v2:z())/2 )
end

function getDeltas(startVec, endVec)
    return endVec:x() - startVec:x(), endVec:y() - startVec:y(), endVec:z() - startVec:z()
end
