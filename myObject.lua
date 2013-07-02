require "myGrabbable"

--[[
    abstract base class myObject: inherits from myGrabbable
        Constructor: myObject(osg::Shape, [OPTIONAL]permxform)  -- pass an osg::Shape such as an osg::Cylinder or osg::Box; may also pass a permanent transform to permanently reorient it
        
        (Lua)bool .selected   -- whether object is selected or not (a Lua bool not an osg bool)
        (Lua)bool .cursorOver   -- whether the cursor is over the object or not
        abstract Vec3f :getCenterInWorldCoords()  -- abstract methods are not implemented here and must be implemented by subclasses
        abstract void :initializeScaling()  -- get ready for subsequent calls to scale()
        abstract void :scale(float)
        abstract (Lua)bool :contains(Vec3f)   -- whether the object contains the point passed as argument
        void :openForEditing()
        void :closeForEditing()
        abstract void :removeObject()  -- removes the object from the environment
        
        Protected members:
        .shapeDrawable  -- the osg::ShapeDrawable which the osg::Shape is attached to
        void :setCenter(Vec3d)  -- for moving the object's center without moving its local center. Using this function is necessary so that the object rotates around its local center and to prevent other undesirable effects
        void :getCenterDisplacement()   -- for getting the displacement that was set using :setCenter()
        
        Private members:
        .xform  -- a PositionAttitudeTransform, which is responsible for moving the object's center (other than movement due to being grabbed, which is handled by the myGrabbable underlying the myObject) such that its local center can remain at local (0,0,0)
]]--

function myObject(osgshape, permxform)
    local shapeDrawable = osg.ShapeDrawable(osgshape)
    local geode = osg.Geode()
    geode:addDrawable(shapeDrawable)
    local object;
    if permxform then
        permxform:addChild(geode)
        object = myGrabbable(permxform)
    else
        object = myGrabbable(geode)
    end
    object.shapeDrawable = shapeDrawable
    object.xform = Transform { position = {0,0,0} }
    object.xform:addChild(object.attach_here)
    object.attach_here = object.xform  -- update the attach_here to the new outermost node in the myObject construct
    
    object.selected = false
    object.cursorOver = false
    
    object.openForEditing = function()
        object.shapeDrawable:setUseDisplayList(false)   -- Shape needs to be re-rendered every frame while it is changed
    end

    object.closeForEditing = function() 
        object.shapeDrawable:setUseDisplayList(true)    -- done modifying Shape, doesn't need to be re-rendered every frame
    end
    
    object.setCenter = function(_, vec)
        object.xform:setPosition(vec)
    end
    
    object.getCenterDisplacement = function()
        return object.xform:getPosition()
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

-- no longer used functions
--[[
function angleDegreesBetween(v1, v2)
    return math.acos((dot_prod_3(v1,v2))/(v1:length()*v2:length()))*180/math.pi
end

function dot_prod_3(v1, v2)
    return v1:x()*v2:x() + v1:y()*v2:y() + v1:z()*v2:z()
end

function x_prod(vec1, vec2)
    return Vecf( vec1:y()*vec2:z() - vec1:z()*vec2:y(), vec1:z()*vec2:x() - vec1:x()*vec2:z(), vec1:x()*vec2:y() - vec1:y()*vec2:x() )
end
]]--

-- debugging
function printVec(vec)
    print("x = ", vec:x(), "; y = ", vec:y(), "; z = ", vec:z())
end