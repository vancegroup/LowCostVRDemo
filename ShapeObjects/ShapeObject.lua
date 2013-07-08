require "myObject"

--[[
    abstract base class ShapeObject: inherits from myObject   -- for rendering osg::Shapes
        Constructor: ShapeObject(osg::Shape, [OPTIONAL]permxform)  -- pass an osg::Shape such as an osg::Cylinder or osg::Box; may also pass a permanent transform to permanently reorient it
        
        implements some of the abstract methods of myObject
        
        Protected members:
        .shapeDrawable  -- the osg::ShapeDrawable which the osg::Shape is attached to
        
]]--

function ShapeObject(osgshape, permxform)
    local shapeDrawable = osg.ShapeDrawable(osgshape)
    local geode = osg.Geode()
    geode:addDrawable(shapeDrawable)
    local grabbable;
    if permxform then
        permxform:addChild(geode)
        grabbable = myGrabbable(permxform)
    else
        grabbable = myGrabbable(geode)
    end
    local object = myObject(grabbable)
    object.shapeDrawable = shapeDrawable
    
    object.setColor = function(_, color)
        object.shapeDrawable:setColor(color)
    end
    
    object.getColor = function()
        return object.shapeDrawable:getColor()
    end
    
    object.openForEditing = function()
        object.shapeDrawable:setUseDisplayList(false)   -- Shape needs to be re-rendered every frame while it is changed
    end

    object.closeForEditing = function() 
        object.shapeDrawable:setUseDisplayList(true)    -- done modifying Shape, doesn't need to be re-rendered every frame
    end
    
    return object
end
