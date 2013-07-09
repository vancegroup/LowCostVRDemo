require "myObject"

--[[
    abstract base class GeometryObject: inherits from myObject   -- for rendering shapes that use osg::Geometry
        Constructor: GeometryObject()
        
        implements some of the abstract methods of myObject
        
        New public members:
        :stretch(newScale, axis)   -- Stretch the GeometryObject in one dimension while leaving the other two alone. Use the same :initializeScaling() as for :scale(). The second parameter should be one of 'x', 'y', or 'z' to indicate which axis to stretch along.
        
        Protected members:
        .geometry  -- the osg::Geometry underlying the GeometryObject
        
        Private members:
        .vertexArray  -- the osg::Vec3Array used as the vertex array for the geometry
        .colors   -- an osg::Vec4Array representing the colors for the object
]]--

function GeometryObject()
    local geode = osg.Geode()
    local grabbable = myGrabbable(geode)
    local geomObject = myObject(grabbable)
    geomObject.geometry = osg.Geometry()
    geode:addDrawable(geomObject.geometry)
    
    geomObject.vertexArray = osg.Vec3Array()
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
    
    geomObject.initializeScaling = function()
        geomObject.initialVertexArray = osg.Vec3Array()
        for i = 1, #geomObject.vertexArray.Item do
            geomObject.initialVertexArray.Item[i] = Vecf(geomObject.vertexArray.Item[i])
        end
    end
    
    geomObject.scale = function(_, newScale)
        print("Scaling to ", newScale)
        for i = 1, #geomObject.vertexArray.Item do
            geomObject.vertexArray.Item[i] = Vecf(geomObject.initialVertexArray.Item[i]) * newScale   -- scales toward or away from (0,0,0) as the center
        end
    end
    
    geomObject.stretch = function(_, newScale, axis)
        print("Stretching to ", newScale)
        if axis == 'x' then
            for i = 1, #geomObject.vertexArray.Item do
                geomObject.vertexArray.Item[i] = Vecf(geomObject.initialVertexArray.Item[i]:x()*newScale, geomObject.initialVertexArray.Item[i]:y(), geomObject.initialVertexArray.Item[i]:z())
            end
        elseif axis == 'y' then
            for i = 1, #geomObject.vertexArray.Item do
                geomObject.vertexArray.Item[i] = Vecf(geomObject.initialVertexArray.Item[i]:x(), geomObject.initialVertexArray.Item[i]:y()*newScale, geomObject.initialVertexArray.Item[i]:z())
            end
        elseif axis == 'z' then
            for i = 1, #geomObject.vertexArray.Item do
                geomObject.vertexArray.Item[i] = Vecf(geomObject.initialVertexArray.Item[i]:x(), geomObject.initialVertexArray.Item[i]:y(), geomObject.initialVertexArray.Item[i]:z()*newScale)
            end
        else
            print("Error: unrecognized argument to stretch(): ", axis)
        end
    end

    geomObject.getCenterInWorldCoords = function()
        return geomObject:getLocalToWorldCoords():preMult(Vecf(0,0,0))   -- the local center is always (0,0,0)
    end
    
    geomObject.removeObject = function()
        RelativeTo.World:removeChild(geomObject.attach_here)
    end
    
    return geomObject
end
