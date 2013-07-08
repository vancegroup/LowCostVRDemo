require "myGeometryObject"
require "gldef"

--[[
    class Pyramid: inherits from (and implements) myObject
        Constructors: Pyramid(color)  -- create a new Pyramid of the specified (Vec4f) color using the interactive draw sequence
                      Pyramid(pyramid_to_copy)   -- create a new Pyramid that is an exact duplicate of the one passed
        
        implements abstract methods of myObject
        
        Additional private members:
        void :setBaseHalfLengths(float, float)  -- x by z dimensions of the base, as HalfLengths
        float, float :getHalfLengths()  -- returns two floats representing the current HalfLengths of the base (x then z)
        void :setHeight(float)
        float :getHeight()
        float, float :getHalfLengthsAtPercentHeight(float)   -- pass the percent up the height, where 1 is the tip and 0 is the base, receive the halfLengths at that height
        
        .vertexArray  -- the osg::Vec3Array used as the vertex array for the geometry
]]--

function Pyramid(arg)  -- both constructors in one function. Pass either a Vec4f color for interactive draw, or an existing Pyramid to copy
    copy = (type(arg) == "table")   -- copy will be true if an object to copy was passed, but false if a color was passed
    
    pyramid = myGeometryObject()
    
    if copy then
        pyramid.vertexArray = arg.vertexArray
    else
        pyramid.vertexArray = osg.Vec3Array()
        pyramid.vertexArray.Item[1] = Vecf(0.05, 0, 0.05)
        pyramid.vertexArray.Item[2] = Vecf(-0.05, 0, 0.05)
        pyramid.vertexArray.Item[3] = Vecf(-0.05, 0, -0.05)
        pyramid.vertexArray.Item[4] = Vecf(0.05, 0, -0.05)
        pyramid.vertexArray.Item[5] = Vecf(0, 0.05, 0)   -- peak
    end
    
    local base = osg.DrawElementsUShort(gldef.GL_QUADS, 0)  -- 0 is the index in pyramid.vertexArray to start from
    base.Item:insert( osgLua.GLushort(3) )   -- does this still refer to the vertices above with a 0-based index? How smart is the Lua binding?
    base.Item:insert( osgLua.GLushort(2) )
    base.Item:insert( osgLua.GLushort(1) )
    base.Item:insert( osgLua.GLushort(0) )
    
    local faces = osg.DrawElementsUShort(gldef.GL_TRIANGLES, 0)
    faces.Item:insert( osgLua.GLushort(0) )
    faces.Item:insert( osgLua.GLushort(1) )
    faces.Item:insert( osgLua.GLushort(4) )
    faces.Item:insert( osgLua.GLushort(1) )
    faces.Item:insert( osgLua.GLushort(2) )
    faces.Item:insert( osgLua.GLushort(4) )
    faces.Item:insert( osgLua.GLushort(2) )
    faces.Item:insert( osgLua.GLushort(3) )
    faces.Item:insert( osgLua.GLushort(4) )
    faces.Item:insert( osgLua.GLushort(3) )
    faces.Item:insert( osgLua.GLushort(0) )
    faces.Item:insert( osgLua.GLushort(4) )
    
    pyramid.geometry:setVertexArray(pyramid.vertexArray)
    pyramid.geometry:addPrimitiveSet(base)
    pyramid.geometry:addPrimitiveSet(faces)

    pyramid:setColor(copy and arg:getColor() or arg)  -- arg could be either a Pyramid or a color
    
    pyramid.getCenterInWorldCoords = Pyramid_getCenterInWorldCoords
    pyramid.initializeScaling = Pyramid_initializeScaling
    pyramid.scale = Pyramid_scale
    pyramid.contains = Pyramid_contains
    pyramid.removeObject = Pyramid_removeObject
    pyramid.getHalfLengthsAtPercentHeight = Pyramid_getHalfLengthsAtPercentHeight
    
    pyramid.setBaseHalfLengths = function(_, xHalfLength, zHalfLength)
        local oldHeight = pyramid:getHeight()
        pyramid.vertexArray.Item[1] = Vecf(xHalfLength, 0, zHalfLength)
        pyramid.vertexArray.Item[2] = Vecf(-xHalfLength, 0, zHalfLength)
        pyramid.vertexArray.Item[3] = Vecf(-xHalfLength, 0, -zHalfLength)
        pyramid.vertexArray.Item[4] = Vecf(xHalfLength, 0, -zHalfLength)
        pyramid.vertexArray.Item[5] = Vecf(0, oldHeight, 0)  -- leave height unchanged
    end
    
    pyramid.getBaseHalfLengths = function()
        return pyramid.vertexArray.Item[1]:x(), pyramid.vertexArray.Item[1]:z()
    end
    
    pyramid.setHeight = function(_, height)
        pyramid.vertexArray.Item[5] = Vecf(0, height, 0)   -- the new peak vertex
    end
    
    pyramid.getHeight = function()
        return pyramid.vertexArray.Item[5]:y()
    end
    
    if copy then
        pyramid:setCenter(arg:getCenterDisplacement())
        RelativeTo.World:addChild(pyramid.attach_here)
        return pyramid
        -- copy complete
    end
    
    -- draw the pyramid
    repeat
        Actions.waitForRedraw()
    until hold_to_draw_button.pressed

    local startLoc = Vecf(wand.position)   -- the location the button was first pressed
    local centerPos = startLoc
    pyramid:setCenter(Vec(startLoc))
    RelativeTo.World:addChild(pyramid.attach_here)
    
    pyramid:openForEditing()
    
    repeat
        local endLoc = Vecf(wand.position)
        centerPos = avgPosf_lock_y(startLoc, endLoc)
        pyramid:setCenter(Vec(centerPos))
        local deltax, deltay, deltaz = getDeltas(startLoc, endLoc)
        deltax, deltay, deltaz = 0.5*math.abs(deltax), 0.5*math.abs(deltay), 0.5*math.abs(deltaz)
        if deltax < 0.05 then deltax = 0.05 end  -- disallow halfLengths less than 0.05
        if deltay < 0.05 then deltay = 0.05 end
        if deltaz < 0.05 then deltaz = 0.05 end
        pyramid:setBaseHalfLengths(deltax, deltaz)
        Actions.waitForRedraw()
    until not hold_to_draw_button.pressed

    -- hold_to_draw_button was released

    repeat
        Actions.waitForRedraw()
    until hold_to_draw_button.pressed

    -- hold_to_draw_button was pressed the second time

    startLoc = Vecf(wand.position)
    
    -- centerPos persists as the coordinates of the center of the base of the pyramid
    repeat
        local endLoc = Vecf(wand.position)
        local deltay = endLoc:y()-startLoc:y()
        if (math.abs(deltay) > 0.05) then
            pyramid:setHeight(math.abs(deltay))
        end
        Actions.waitForRedraw()
    until not hold_to_draw_button.pressed

    -- hold_to_draw_button was released
    
    pyramid:closeForEditing()
    
    -- done creating pyramid
    return pyramid
end

function Pyramid_getCenterInWorldCoords(pyramid)
    return pyramid:getLocalToWorldCoords():preMult(Vecf(0,0,0))   -- the local center is always (0,0,0) for the pyramid
end

function Pyramid_initializeScaling(pyramid)
    pyramid.initialHalfLengthX, pyramid.initialHalfLengthZ = pyramid:getBaseHalfLengths()
    pyramid.initialHeight = pyramid:getHeight()
end

function Pyramid_scale(pyramid, newScale)
    pyramid:setBaseHalfLengths(pyramid.initialHalfLengthX*newScale, pyramid.initialHalfLengthZ*newScale)
    pyramid:setHeight(pyramid.initialHeight*newScale)
end

function Pyramid_contains(pyramid, vec)
    local vecInLocalCoords = pyramid:getWorldToLocalCoords():preMult(vec)
    local percentHeight = vecInLocalCoords:y() / pyramid:getHeight()
    if percentHeight > 1 or percentHeight < 0 then -- too high or too low to hit the pyramid
        return false
    else
        local halfLengthX, halfLengthZ = pyramid:getHalfLengthsAtPercentHeight(percentHeight)
        if math.abs(vecInLocalCoords:x()) > halfLengthX or math.abs(vecInLocalCoords:z()) > halfLengthZ then
            return false
        else
            return true
        end
    end
end

function Pyramid_removeObject(pyramid)
    RelativeTo.World:removeChild(pyramid.attach_here)
end
    
function Pyramid_getHalfLengthsAtPercentHeight(pyramid, percent)
    local halfLengthX, halfLengthZ = pyramid:getBaseHalfLengths()
    return (1.0-percent)*halfLengthX, (1.0-percent)*halfLengthZ
end
