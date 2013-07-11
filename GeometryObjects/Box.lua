require "GeometryObjects.GeometryObject"
require "gldef"

--[[
    class Box: inherits from (and implements) GeometryObject
        Constructors: Box(color)  -- create a new Box of the specified (Vec4f) color using the interactive draw sequence
                      Box(Box_to_copy)   -- create a new Box that is an exact duplicate of the one passed
        
        implements abstract methods of myObject
        
        Additional private members:
        void :setHalfLengths(float, float, float)  -- x, y, z dimensions of the box, as HalfLengths
        float, float, float :getHalfLengths()  -- returns three floats representing the current HalfLengths of the box (x,y,z)
]]--

function Box(arg)  -- both constructors in one function. Pass either a Vec4f color for interactive draw, or an existing Box to copy
    copy = (type(arg) == "table")   -- copy will be true if an object to copy was passed, but false if a color was passed
    
    box = GeometryObject()
    
    box.setHalfLengths = Box_setHalfLengths
    box.getHalfLengths = Box_getHalfLengths
    box.contains = Box_contains
    
    if copy then
        for i = 1, #arg.vertexArray.Item do
            box.vertexArray.Item[i] = Vecf(arg.vertexArray.Item[i])
        end
    else
        box:setHalfLengths(0.01, 0.01, 0.01)
    end
    
    local faceStrip = osg.DrawElementsUShort(gldef.GL_QUAD_STRIP, 0)  -- the top, back, bottom, and front faces in that order
    faceStrip.Item:insert( osgLua.GLushort(0) )   -- This refers to the vertices in vertexArray with a 0-based index. So '3' here refers to the 4th index, which is vertexArray.Item[4]. Blame the Lua binding for this.
    faceStrip.Item:insert( osgLua.GLushort(1) )
    faceStrip.Item:insert( osgLua.GLushort(2) )
    faceStrip.Item:insert( osgLua.GLushort(3) )
    faceStrip.Item:insert( osgLua.GLushort(4) )
    faceStrip.Item:insert( osgLua.GLushort(5) )
    faceStrip.Item:insert( osgLua.GLushort(6) )
    faceStrip.Item:insert( osgLua.GLushort(7) )
    faceStrip.Item:insert( osgLua.GLushort(0) )
    faceStrip.Item:insert( osgLua.GLushort(1) )
    
    local sides = osg.DrawElementsUShort(gldef.GL_QUADS, 0)  -- the right and left sides in that order
    sides.Item:insert( osgLua.GLushort(0) )
    sides.Item:insert( osgLua.GLushort(2) )
    sides.Item:insert( osgLua.GLushort(6) )
    sides.Item:insert( osgLua.GLushort(4) )
    sides.Item:insert( osgLua.GLushort(1) )
    sides.Item:insert( osgLua.GLushort(3) )
    sides.Item:insert( osgLua.GLushort(7) )
    sides.Item:insert( osgLua.GLushort(5) )

    box.geometry:setVertexArray(box.vertexArray)
    box.geometry:addPrimitiveSet(faceStrip)
    box.geometry:addPrimitiveSet(sides)

    box:setColor(copy and arg:getColor() or arg)  -- arg could be either a box or a color
    
    if copy then
        box:setCenter(arg:getCenterDisplacement())
        World:addChild(box.attach_here)
        return box
        -- copy complete
    end
    
    -- draw the box
    repeat
        Actions.waitForRedraw()
    until hold_to_draw_button.pressed
    
    World:addChild(box.attach_here)
    local startLoc = box:getCursorPositionInConstructionCoords()   -- the location the button was first pressed
    box:setCenter(Vec(startLoc))
    
    box:openForEditing()
    
    repeat
        local endLoc = box:getCursorPositionInConstructionCoords()
        box:setCenter(Vec(avgPosf(startLoc, endLoc)))
        local deltax, deltay, deltaz = getDeltas(startLoc, endLoc)
        deltax, deltay, deltaz = 0.5*math.abs(deltax), 0.5*math.abs(deltay), 0.5*math.abs(deltaz)
        if deltax < 0.01 then deltax = 0.01 end  -- disallow halfLengths less than 0.01
        if deltay < 0.01 then deltay = 0.01 end
        if deltaz < 0.01 then deltaz = 0.01 end
        box:setHalfLengths(deltax, deltay, deltaz)
        Actions.waitForRedraw()
    until not hold_to_draw_button.pressed

    -- hold_to_draw_button was released
    
    box:closeForEditing()
    
    -- done creating box
    return box
end

Box_setHalfLengths = function(_, xHalfLength, yHalfLength, zHalfLength)
    box.vertexArray.Item[1] = Vecf(xHalfLength, yHalfLength, zHalfLength)  -- front right top
    box.vertexArray.Item[2] = Vecf(-xHalfLength, yHalfLength, zHalfLength)  -- front left top
    box.vertexArray.Item[3] = Vecf(xHalfLength, yHalfLength, -zHalfLength)  -- back right top
    box.vertexArray.Item[4] = Vecf(-xHalfLength, yHalfLength, -zHalfLength)  -- back left top
    box.vertexArray.Item[5] = Vecf(xHalfLength, -yHalfLength, -zHalfLength)  -- back right bottom
    box.vertexArray.Item[6] = Vecf(-xHalfLength, -yHalfLength, -zHalfLength)  -- back left bottom
    box.vertexArray.Item[7] = Vecf(xHalfLength, -yHalfLength, zHalfLength)  -- front right bottom
    box.vertexArray.Item[8] = Vecf(-xHalfLength, -yHalfLength, zHalfLength)  -- front left bottom
end

Box_getHalfLengths = function()
    return box.vertexArray.Item[1]:x(), box.vertexArray.Item[1]:y(), box.vertexArray.Item[1]:z()
end

function Box_contains(box, vec)
    local vecInLocalCoords = box:getWorldToLocalCoords():preMult(vec)
    local halfLengthX, halfLengthY, halfLengthZ = box:getHalfLengths()
    if math.abs(vecInLocalCoords:x()) > halfLengthX
        or math.abs(vecInLocalCoords:y()) > halfLengthY
        or math.abs(vecInLocalCoords:z()) > halfLengthZ
        then return false
    else return true
    end
end
