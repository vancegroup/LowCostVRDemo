require "myObject"

--[[
    abstract base class GeometryObject: inherits from myObject   -- for rendering shapes that use osg::Geometry
        Constructor: GeometryObject()
        
        implements some of the abstract methods of myObject
        
        New public members:
        :stretch(newScale, axis)   -- Stretch the GeometryObject in one dimension while leaving the other two alone. Use the same :initializeScaling() as for :scale(). The second parameter should be one of 'x', 'y', or 'z' to indicate which axis to stretch along.
        abstract string .type   -- the type of GeometryObject ("Box", "Cone", "Cylinder", "Pyramid", or "Sphere")
        
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
        geomObject.geometry:dirtyBound()   -- force a recalculation of the osg::BoundingBox the next time it is requested
    end
    
    geomObject.initializeScaling = function()
        geomObject.initialVertexArray = osg.Vec3Array()
        for i = 1, #geomObject.vertexArray.Item do
            geomObject.initialVertexArray.Item[i] = Vecf(geomObject.vertexArray.Item[i])
        end
    end
    
    geomObject.scale = function(_, newScale)
        for i = 1, #geomObject.vertexArray.Item do
            geomObject.vertexArray.Item[i] = Vecf(geomObject.initialVertexArray.Item[i]) * newScale   -- scales toward or away from (0,0,0) as the center
        end
    end
    
    geomObject.stretch = function(_, newScale, axis)
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
        World:removeChild(geomObject.attach_here)
    end
    
    -- generic implementation of collisions for arbitrary GeometryObjects. Uses osg::BoundingBox(d/f) in the local coordinate system. Not as accurate as it could be, but pretty simple to put together.
    geomObject.contains = function(_, vec)
        local vecInLocalCoords = geomObject:getWorldToLocalCoords():preMult(vec)
        local boundingBox = geode:getBoundingBox()
        return boundingBox:contains(vecInLocalCoords)
    end
    
    --[[Actions.addFrameAction(function()
        while true do
            print("Object's center (world coords):", geomObject:getCenterInWorldCoords())
            print("Rotation components are nonzero in:")
            if not geomObject.xform_track.Matrix:getRotate():zeroRotation() then print("xform_track") end
            if not geomObject.xform_save.Matrix:getRotate():zeroRotation() then print("xform_save") end
            if not cursor.xform_calibration.Matrix:getRotate():zeroRotation() then print("xform_calibration") end
            if not WorldGrabbable.xform_track.Matrix:getRotate():zeroRotation() then print("World's xform_track") end
            if not WorldGrabbable.xform_save.Matrix:getRotate():zeroRotation() then print("World's xform_save") end
            if not osg.MatrixTransform().Matrix:getRotate():zeroRotation() then print("don't trust any of the above rotation data") end
            Actions.waitForRedraw()
        end
    end)]]--
    
    return geomObject
end
