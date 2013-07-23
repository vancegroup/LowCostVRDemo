require "GeometryObjects.GeometryObject"
require "gldef"

--[[
    class Sphere: inherits from (and implements) GeometryObject
        Constructors: Sphere(color)  -- create a new Sphere of the specified (Vec4f) color using the interactive draw sequence
                      Sphere(sphere_to_copy)   -- create a new Sphere that is an exact duplicate of the one passed
        
        implements abstract methods of myObject
        
        Additional private members:
        void :setRadius(float)
        float :getRadius()
]]--

function Sphere(arg)  -- both constructors in one function. Pass either a Vec4f color for interactive draw, or an existing Sphere to copy
    copy = (type(arg) == "table")   -- copy will be true if an object to copy was passed, but false if a color was passed
    
    sphere = GeometryObject()
    
    sphere.type = "Sphere"
    sphere.setRadius = Sphere_setRadius
    sphere.getRadius = Sphere_getRadius
    --sphere.contains = Sphere_contains
    
    if copy then
        for i = 1, #arg.vertexArray.Item do
            sphere.vertexArray.Item[i] = Vecf(arg.vertexArray.Item[i])
        end
    else
        sphere:setRadius(0.05)
    end
    
    sphere.geometry:setVertexArray(sphere.vertexArray)
    
    -- we will create a series of QUAD_STRIP:
    --      the 1st strip is bounded by the equator and the 1st parallel north of it
    --      through the 10th strip is bounded by the 9th parallel and the 10th (north)
    --      the 11th strip is bounded by the equator and the 1st parallel south of it (the 11th parallel)
    --      through the 20th strip is bounded by the 9th parallel south (the 19th parallel) and the 10th (20th) parallel
    --      then we will have 2 TRIANGLE_FAN, one for between the 10th parallel and the north pole, the other for between the 20th parallel and the south pole
    
    -- north hemisphere
    for i = 1, 10 do
        local strip = osg.DrawElementsUShort(gldef.GL_QUAD_STRIP, 0)  -- 0 is the index in sphere.vertexArray to start from
        for j = 0, 49 do
            strip.Item:insert( osgLua.GLushort( (i-1)*50+j ) )     -- These calls refer to the vertices in sphere.vertexArray with a 0-based index. So a '3' here would refer to the 4th index, which is vertexArray.Item[4]. Blame the Lua binding for this.
            strip.Item:insert( osgLua.GLushort( i*50+j ) )   -- this call is the vertex above (toward the north pole from) the one from the call above.
        end
        strip.Item:insert( osgLua.GLushort( (i-1)*50 ) )
        strip.Item:insert( osgLua.GLushort( i*50 ) )    -- these two calls finish the QUAD_STRIP by wrapping it around to the beginning
        sphere.geometry:addPrimitiveSet(strip)
    end
    
    -- first strip south of equator
    local strip = osg.DrawElementsUShort(gldef.GL_QUAD_STRIP, 0)
    for j = 0, 49 do
        strip.Item:insert( osgLua.GLushort( j ) )   -- the vertex on the equator
        strip.Item:insert( osgLua.GLushort( 550+j ) )    -- the vertex directly below (toward the south pole from) it
    end
    strip.Item:insert( osgLua.GLushort( 0 ) )
    strip.Item:insert( osgLua.GLushort( 550 ) )    -- these two calls finish the QUAD_STRIP by wrapping it around to the beginning
    sphere.geometry:addPrimitiveSet(strip)
    
    -- the rest of the strips in the south hemisphere
    for i = 12, 20 do
        local strip = osg.DrawElementsUShort(gldef.GL_QUAD_STRIP, 0)
        for j = 0, 49 do
            strip.Item:insert( osgLua.GLushort( (i-1)*50+j ) )     -- These calls refer to the vertices in sphere.vertexArray with a 0-based index. So a '3' here would refer to the 4th index, which is vertexArray.Item[4]. Blame the Lua binding for this.
            strip.Item:insert( osgLua.GLushort( i*50+j ) )   -- this call is the vertex below (toward the south pole from) the one from the call above.
        end
        strip.Item:insert( osgLua.GLushort( (i-1)*50 ) )
        strip.Item:insert( osgLua.GLushort( i*50 ) )    -- these two calls finish the QUAD_STRIP by wrapping it around to the beginning
        sphere.geometry:addPrimitiveSet(strip)
    end
    
    local topCap = osg.DrawElementsUShort(gldef.GL_TRIANGLE_FAN, 0)
    topCap.Item:insert( osgLua.GLushort(1050) )  -- Vertex 1051: the north pole, the anchor point for the TRIANGLE_FAN  (remember this is 0-based, so 1050 here means vertexArray.Item[1051])
    for i = 500, 549 do  -- these 50 vertices wrap around the 10th parallel
        topCap.Item:insert( osgLua.GLushort(i) )
    end
    topCap.Item:insert( osgLua.GLushort(500) )   -- finishes the TRIANGLE_FAN by wrapping it around to the beginning
    sphere.geometry:addPrimitiveSet(topCap)
    
    local bottomCap = osg.DrawElementsUShort(gldef.GL_TRIANGLE_FAN, 0)
    bottomCap.Item:insert( osgLua.GLushort(1051) )  -- Vertex 1052: the south pole, the anchor point for the TRIANGLE_FAN  (remember this is 0-based, so 1050 here means vertexArray.Item[1051])
    for i = 1000, 1049 do  -- these 50 vertices wrap around the 20th parallel
        bottomCap.Item:insert( osgLua.GLushort(i) )
    end
    bottomCap.Item:insert( osgLua.GLushort(1000) )   -- finishes the TRIANGLE_FAN by wrapping it around to the beginning
    sphere.geometry:addPrimitiveSet(bottomCap)

    
    sphere:setColor(copy and arg:getColor() or arg)  -- arg could be either a Sphere or a color
    
    if copy then
        sphere:setCenter(arg:getCenterDisplacement())
        sphere.xform_track:setMatrix(arg.xform_track.Matrix)
        sphere.xform_save:setMatrix(arg.xform_save.Matrix)
        World:addChild(sphere.attach_here)        
        return sphere
        -- copy complete
    end
    
    -- draw the sphere
    repeat
        Actions.waitForRedraw()
    until hold_to_draw_button.pressed

    World:addChild(sphere.attach_here)
    local startLoc = sphere:getCursorPositionInConstructionCoords()   -- the location the button was first pressed
    sphere:setCenter(Vec(startLoc))
    
    sphere:openForEditing()
    sphere:initializeScaling()   -- we will construct the sphere by scaling it, because this is much easier computation-wise than rewriting all of its vertices every time the mouse moves during construction
    
    repeat
        local endLoc = sphere:getCursorPositionInConstructionCoords()
        sphere:setCenter(Vec(avgPosf(startLoc, endLoc)))
        local newradius = (endLoc - startLoc):length() / 2
        local scaleFactor = newradius/0.05
        if scaleFactor > 1 then   -- maintain minimum radius of 0.05
            sphere:scale(scaleFactor)
        end
        Actions.waitForRedraw()
    until not hold_to_draw_button.pressed

    -- hold_to_draw_button was released

    sphere:closeForEditing()
    
    -- done creating sphere
    return sphere
end

-- Sphere's vertexArray is structured:
--      Index 1-50:   Ring of vertices around the equator
--      Index i*50+1-i*50+50:    Ring of vertices around the ith parallel North (i 1 through 10, i=0 is the equator)   - the 10th parallel is closest to the north pole
--      Index i*50+1-i*50+50:    Ring of vertices around the ith parallel South (i 11 through 20, i=0 is the equator)   - the 20th parallel is closest to the south pole
--      Index 1051:   North pole
--      Index 1052:   South pole
Sphere_setRadius = function(sphere, radius)
    for i = 0, 10 do   -- does the equator (i=0) with the north hemisphere's vertices (i=1 through 10)
        for j = 1, 50 do
            theta = Degrees(j/50*360)
            phi = Degrees(i/11*90)
            sphere.vertexArray.Item[i*50+j] = Vecf(radius*math.cos(theta)*math.cos(phi), radius*math.sin(phi), radius*math.sin(theta)*math.cos(phi))
        end
    end
    for i = 11, 20 do  -- does the south hemisphere's vertices
        for j = 1, 50 do
            theta = Degrees(j/50*360)
            phi = Degrees( (i-10)/11*90 )
            sphere.vertexArray.Item[i*50+j] = Vecf(radius*math.cos(theta)*math.cos(phi), -radius*math.sin(phi), radius*math.sin(theta)*math.cos(phi))
        end
    end
    sphere.vertexArray.Item[1051] = Vecf(0, radius, 0)
    sphere.vertexArray.Item[1052] = Vecf(0, -radius, 0)
end
    
Sphere_getRadius = function(sphere)
    return sphere.vertexArray.Item[50]:x()   -- Vertex 50 is at 360 degrees, directly in the positive x-direction
end

-- strictly correct implementation of contains for Sphere; only works correctly if no slicing or 1-D stretching has occurred
--[[
function Sphere_contains(sphere, vec)
    local vecInLocalCoords = sphere:getWorldToLocalCoords():preMult(vec)
    local distFromCenter = vecInLocalCoords:length()
    if distFromCenter > sphere:getRadius() then return false else return true end
end
]]--
