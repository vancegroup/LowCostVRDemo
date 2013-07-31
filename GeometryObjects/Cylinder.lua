require "GeometryObjects.GeometryObject"
require "gldef"

--[[
    class Cylinder: inherits from (and implements) GeometryObject
        Constructors: Cylinder(color)  -- create a new Cylinder of the specified (Vec4f) color using the interactive draw sequence
                      Cylinder(cylinder_to_copy)   -- create a new Cylinder that is an exact duplicate of the one passed
        
        implements abstract methods of myObject
        
        Additional private members:
        void :setRadius(float)
        float :getRadius()
        void :setHeight(float)
        float :getHeight()
]]--

local MIN_CYLINDER_RADIUS = 0.01
local MIN_CYLINDER_HEIGHT = 0.002

function Cylinder(arg)  -- both constructors in one function. Pass either a Vec4f color for interactive draw, or an existing Cylinder to copy
    copy = (type(arg) == "table")   -- copy will be true if an object to copy was passed, but false if a color was passed
    
    cylinder = GeometryObject()
    
    cylinder.type = "Cylinder"
    cylinder.setRadius = Cylinder_setRadius
    cylinder.getRadius = Cylinder_getRadius
    cylinder.setHeight = Cylinder_setHeight
    cylinder.getHeight = Cylinder_getHeight
    --cylinder.contains = Cylinder_contains
    
    if copy then
        for i = 1, #arg.vertexArray.Item do
            cylinder.vertexArray.Item[i] = Vecf(arg.vertexArray.Item[i])
        end
    else
        cylinder.vertexArray.Item[1] = Vecf(0, MIN_CYLINDER_HEIGHT, 0)   -- very much breaking encapsulation by knowing the implementation; this will force the subsequent call to getRadius to create everything at the correct heights because getHeight will only check Item[1]
        cylinder:setRadius(MIN_CYLINDER_RADIUS)
    end
    
    local sides = osg.DrawElementsUShort(gldef.GL_QUAD_STRIP, 0)  -- 0 is the index in cylinder.vertexArray to start from
    for i = 99, 0, -1 do  -- specify in the order to produce the correct normals
        sides.Item:insert( osgLua.GLushort(i) )     -- These calls refer to the vertices in cylinder.vertexArray with a 0-based index. So '3' here refers to the 4th index, which is vertexArray.Item[4]. Blame the Lua binding for this.
        sides.Item:insert( osgLua.GLushort(i+100) )
    end
    sides.Item:insert( osgLua.GLushort(0) )   -- these 2 calls create the last face in the QUAD_STRIP by wrapping it around to the beginning
    sides.Item:insert( osgLua.GLushort(100) )
    
    local top = osg.DrawElementsUShort(gldef.GL_TRIANGLE_FAN, 0)
    top.Item:insert( osgLua.GLushort(200) )  -- Vertex 201: the anchor point for the TRIANGLE_FAN  (remember this is 0-based, so 200 here means vertexArray.Item[201])
    for i = 99, 0, -1 do  -- specify in the order to produce the correct normals
        top.Item:insert( osgLua.GLushort(i) )
    end
    top.Item:insert( osgLua.GLushort(0) )   -- finishes the TRIANGLE_FAN by wrapping it around to the beginning
    
    local bottom = osg.DrawElementsUShort(gldef.GL_TRIANGLE_FAN, 0)
    bottom.Item:insert( osgLua.GLushort(201) )  -- Vertex 202: the anchor point for the TRIANGLE_FAN  (remember this is 0-based, so 201 here means vertexArray.Item[202])
    for i = 100, 199 do
        bottom.Item:insert( osgLua.GLushort(i) )
    end
    bottom.Item:insert( osgLua.GLushort(100) )  -- finishes the TRIANGLE_FAN by wrapping it around to the beginning
    
    cylinder.geometry:setVertexArray(cylinder.vertexArray)
    cylinder.geometry:addPrimitiveSet(sides)
    cylinder.geometry:addPrimitiveSet(top)
    cylinder.geometry:addPrimitiveSet(bottom)

    cylinder:setColor(copy and arg:getColor() or arg)  -- arg could be either a Cylinder or a color
    
    if copy then
        cylinder:setCenter(arg:getCenterDisplacement())
        cylinder.xform_track:setMatrix(arg.xform_track.Matrix)
        cylinder.xform_save:setMatrix(arg.xform_save.Matrix)
        World:addChild(cylinder.attach_here)
        return cylinder
        -- copy complete
    end
    
    -- draw the cylinder
    repeat
        Actions.waitForRedraw()
    until hold_to_draw_button.pressed

    World:addChild(cylinder.attach_here)
    local startLoc = cylinder:getCursorPositionInConstructionCoords()   -- the location the button was first pressed
    local centerPos = startLoc
    --print("initial cursor position in construction coords: ", centerPos)
    cylinder:setCenter(Vec(startLoc))
    --print("setting cylinder center to (should have |z| < 1): ", centerPos)
    
    cylinder:openForEditing()
    
    repeat
        local endLoc = cylinder:getCursorPositionInConstructionCoords()
        centerPos = avgPosf_lock_y(startLoc, endLoc)
        cylinder:setCenter(Vec(centerPos))
        local deltax, deltay, deltaz = getDeltas(startLoc, endLoc)
        local newradius = (deltax^2+deltaz^2)^0.5/2.0  -- the diameter is the xz-distance between startLoc and endLoc. Divide by 2 to get the radius. xz-distance is used because the cylinder expands in the xz-plane and cannot be expanded in y during this step (making the base).
        if newradius > MIN_CYLINDER_RADIUS then
            cylinder:setRadius(newradius)
        end
        Actions.waitForRedraw()
    until not hold_to_draw_button.pressed

    -- hold_to_draw_button was released

    repeat
        Actions.waitForRedraw()
    until hold_to_draw_button.pressed

    -- hold_to_draw_button was pressed the second time

    startLoc = cylinder:getCursorPositionInConstructionCoords()
    
    -- centerPos persists as the coordinates of the center of the base of the cylinder
    repeat
        local endLoc = cylinder:getCursorPositionInConstructionCoords()
        local deltay = endLoc:y()-startLoc:y()
        if (math.abs(deltay) > MIN_CYLINDER_HEIGHT) then
            cylinder:setHeight(math.abs(deltay))
        end
        cylinder:setCenter(Vec(centerPos:x(), centerPos:y()+0.5*deltay, centerPos:z()))   -- the center is halfway up the height
        Actions.waitForRedraw()
    until not hold_to_draw_button.pressed

    -- hold_to_draw_button was released
    
    cylinder:closeForEditing()
    
    -- done creating cylinder
    return cylinder
end

-- Cylinder's vertexArray is structured:
--      Index 1-100:   Ring of vertices representing the boundary of the top
--      Index 101-200:    Ring of vertices representing the boundary of the bottom
--      Index 201:      Center of the top face
--      Index 202:      Center of the bottom face
Cylinder_setRadius = function(cylinder, radius)
    local oldHeight = cylinder:getHeight()
    for i = 1, 100 do
        degrees = Degrees(i/100*360)
        cylinder.vertexArray.Item[i] = Vecf(radius*math.cos(degrees), oldHeight/2, radius*math.sin(degrees))
    end
    for i = 1, 100 do
        degrees = Degrees(i/100*360)
        cylinder.vertexArray.Item[i+100] = Vecf(radius*math.cos(degrees), -oldHeight/2, radius*math.sin(degrees))
    end
    cylinder.vertexArray.Item[201] = Vecf(0, oldHeight/2, 0)
    cylinder.vertexArray.Item[202] = Vecf(0, -oldHeight/2, 0)
end
    
Cylinder_getRadius = function(cylinder)
    return cylinder.vertexArray.Item[100]:x()   -- Vertex 100 is at 360 degrees, directly in the positive x-direction
end

Cylinder_setHeight = function(cylinder, height)
    for i = 1, 100 do
        oldVec = cylinder.vertexArray.Item[i]
        cylinder.vertexArray.Item[i] = Vecf(oldVec:x(), height/2, oldVec:z())
    end
    for i = 101, 200 do
        oldVec = cylinder.vertexArray.Item[i]
        cylinder.vertexArray.Item[i] = Vecf(oldVec:x(), -height/2, oldVec:z())
    end
    cylinder.vertexArray.Item[201] = Vecf(0, height/2, 0)
    cylinder.vertexArray.Item[202] = Vecf(0, -height/2, 0)
end

Cylinder_getHeight = function(cylinder)
    return 2*cylinder.vertexArray.Item[1]:y()
end

-- strictly correct implementation of contains for Cylinder; only works correctly if no slicing or 1-D stretching has occurred
--[[    
function Cylinder_contains(cylinder, vec)
    local vecInLocalCoords = cylinder:getWorldToLocalCoords():preMult(vec)
    if math.abs(vecInLocalCoords:y()) > cylinder:getHeight()/2.0 then
        return false  -- too high or too low
    end
    local xzDistanceFromOrigin = (vecInLocalCoords:x()^2+vecInLocalCoords:z()^2)^0.5
    if xzDistanceFromOrigin > cylinder:getRadius() then
        return false  -- outside the boundary
    else
        return true
    end
end
]]--
