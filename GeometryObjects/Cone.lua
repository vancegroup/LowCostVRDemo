require "GeometryObjects.GeometryObject"
require "gldef"

--[[
    class Cone: inherits from (and implements) GeometryObject
        Constructors: Cone(color)  -- create a new Cone of the specified (Vec4f) color using the interactive draw sequence
                      Cone(cone_to_copy)   -- create a new Cone that is an exact duplicate of the one passed
        
        implements abstract methods of myObject
        
        Additional private members:
        void :setRadius(float)
        float :getRadius()
        void :setHeight(float)
        float :getHeight()
]]--

function Cone(arg)  -- both constructors in one function. Pass either a Vec4f color for interactive draw, or an existing Cone to copy
    copy = (type(arg) == "table")   -- copy will be true if an object to copy was passed, but false if a color was passed
    
    cone = GeometryObject()
    
    cone.setRadius = Cone_setRadius
    cone.getRadius = Cone_getRadius
    cone.setHeight = Cone_setHeight
    cone.getHeight = Cone_getHeight
    cone.contains = Cone_contains
    
    if copy then
        for i = 1, #arg.vertexArray.Item do
            cone.vertexArray.Item[i] = Vecf(arg.vertexArray.Item[i])
        end
    else
        cone:setRadius(0.05)
        cone:setHeight(0.05)
    end
    
    local sides = osg.DrawElementsUShort(gldef.GL_TRIANGLE_FAN, 0)  -- 0 is the index in cone.vertexArray to start from
    sides.Item:insert( osgLua.GLushort(100) )  -- Vertex 101: the peak  (remember this is 0-based, so 100 here means vertexArray.Item[101])
    for i = 0, 99 do
        sides.Item:insert( osgLua.GLushort(i) )     -- These calls refer to the vertices in cone.vertexArray with a 0-based index. So '3' here refers to the 4th index, which is vertexArray.Item[4]. Blame the Lua binding for this.
    end
    sides.Item:insert( osgLua.GLushort(0) )  -- finishes the TRIANGLE_FAN by wrapping it around to the beginning
    
    local base = osg.DrawElementsUShort(gldef.GL_TRIANGLE_FAN, 0)
    base.Item:insert( osgLua.GLushort(101) )  -- Vertex 102: the anchor point for the TRIANGLE_FAN  (remember this is 0-based, so 101 here means vertexArray.Item[102])
    for i = 99, 0, -1 do  -- specify in the order to produce the correct normals
        base.Item:insert( osgLua.GLushort(i) )
    end
    base.Item:insert( osgLua.GLushort(99) )   -- finishes the TRIANGLE_FAN by wrapping it around to the beginning
    
    cone.geometry:setVertexArray(cone.vertexArray)
    cone.geometry:addPrimitiveSet(sides)
    cone.geometry:addPrimitiveSet(base)

    cone:setColor(copy and arg:getColor() or arg)  -- arg could be either a Cone or a color
    
    if copy then
        cone:setCenter(arg:getCenterDisplacement())
        World:addChild(cone.attach_here)
        return cone
        -- copy complete
    end
    
    -- draw the cone
    repeat
        Actions.waitForRedraw()
    until hold_to_draw_button.pressed

    World:addChild(cone.attach_here)
    local startLoc = cone:getCursorPositionInConstructionCoords()   -- the location the button was first pressed
    local centerPos = startLoc
    cone:setCenter(Vec(startLoc))
    
    cone:openForEditing()
    
    repeat
        local endLoc = cone:getCursorPositionInConstructionCoords()
        centerPos = avgPosf_lock_y(startLoc, endLoc)
        cone:setCenter(Vec(centerPos))
        local deltax, deltay, deltaz = getDeltas(startLoc, endLoc)
        local newradius = (deltax^2+deltaz^2)^0.5/2.0  -- the diameter is the xz-distance between startLoc and endLoc. Divide by 2 to get the radius. xz-distance is used because the cone expands in the xz-plane and cannot be expanded in y during this step (making the base).
        if newradius > 0.05 then
            cone:setRadius(newradius)
        end
        Actions.waitForRedraw()
    until not hold_to_draw_button.pressed

    -- hold_to_draw_button was released

    repeat
        Actions.waitForRedraw()
    until hold_to_draw_button.pressed

    -- hold_to_draw_button was pressed the second time

    startLoc = cone:getCursorPositionInConstructionCoords()
    
    repeat
        local endLoc = cone:getCursorPositionInConstructionCoords()
        local deltay = endLoc:y()-startLoc:y()
        if deltay > 0.05 then
            cone:setHeight(deltay)
        end
        Actions.waitForRedraw()
    until not hold_to_draw_button.pressed

    -- hold_to_draw_button was released
    
    cone:closeForEditing()
    
    -- done creating cone
    return cone
end

-- Cone's vertexArray is structured:
--      Index 1-100:   Ring of vertices representing the boundary of the base
--      Index 101:   Peak
--      Index 102:   Center of the base  (this is always (0,0,0), so this point acts as the center of the cone for scaling/rotating operations)
Cone_setRadius = function(cone, radius)
    for i = 1, 100 do
        degrees = Degrees(i/100*360)
        cone.vertexArray.Item[i] = Vecf(radius*math.cos(degrees), 0, radius*math.sin(degrees))
    end
end
    
Cone_getRadius = function(cone)
    return cone.vertexArray.Item[100]:x()   -- Vertex 100 is at 360 degrees, directly in the positive x-direction
end

Cone_setHeight = function(cone, height)
    cone.vertexArray.Item[101] = Vecf(0, height, 0)
    cone.vertexArray.Item[102] = Vecf(0, 0, 0)
end

Cone_getHeight = function(cone)
    return cone.vertexArray.Item[101]:y()   -- y-coord of the peak
end
    
function Cone_contains(cone, vec)
    local vecInLocalCoords = cone:getWorldToLocalCoords():preMult(vec)
    if vecInLocalCoords:y() > cone:getHeight() or vecInLocalCoords:y() < 0 then
        return false  -- too high or too low
    end
    local radius = (1.0-vecInLocalCoords:y()/cone:getHeight())*cone:getRadius()
    local xzDistanceFromCenter = (vecInLocalCoords:x()^2+vecInLocalCoords:z()^2)^0.5
    if xzDistanceFromCenter > radius then
        return false  -- outside the boundary
    else
        return true
    end
end
