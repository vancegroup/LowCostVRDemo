require "myObject"

--[[
    abstract base class myGeometryObject: inherits from myObject   -- for rendering shapes that use osg::Geometry
        Constructor: myGeometryObject()
        
        implements some of the abstract methods of myObject
        
        Protected members:
        .geometry  -- the osg::Geometry underlying the myGeometryObject
        
        Private members:
        .colors   -- an osg::Vec4Array representing the colors for the object
]]--

function myGeometryObject()
    local geode = osg.Geode()
    local grabbable = myGrabbable(geode)
    local geomObject = myObject(grabbable)
    geomObject.geometry = osg.Geometry()
    geode:addDrawable(geomObject.geometry)
    
    geomObject.colors = osg.Vec4Array()
    geomObject.colors.Item[1] = Vecf(1.0, 1.0, 1.0, 1.0)  -- default to white
    geomObject.geometry:setColorArray(geomObject.colors)
    geomObject.geometry:setColorBinding(osg.Geometry.AttributeBinding.BIND_OVERALL)
    
    geomObject.setColor = function(_, color)
        geomObject.colors.Item[1] = color
    end
    
    geomObject.getColor = function()
        return geomObject.colors.Item[1]
    end
    
    geomObject.openForEditing = function()
        geomObject.geometry:setUseDisplayList(false)   -- object needs to be re-rendered every frame while it is changed
    end

    geomObject.closeForEditing = function() 
        geomObject.geometry:setUseDisplayList(true)    -- done modifying object, doesn't need to be re-rendered every frame
    end
    
    return geomObject
end
