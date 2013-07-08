require "gldef"

local pyramidGeode = osg.Geode()
local pyramidGeometry = osg.Geometry()
pyramidGeode:addDrawable(pyramidGeometry)

local pyramidVertices = osg.Vec3Array()
pyramidVertices.Item[1] = Vecf(0, 0, 0)  -- front left
pyramidVertices.Item[2] = Vecf(1, 0, 0)  -- front right
pyramidVertices.Item[3] = Vecf(1, 1, 0)  -- back right
pyramidVertices.Item[4] = Vecf(0, 1, 0)  -- back left
pyramidVertices.Item[5] = Vecf(.5, .5, 1)   -- peak
pyramidVertices.Item[6] = Vecf(.5, .5, 2)  -- super high peak, just to see if Item[6] is used
pyramidGeometry:setVertexArray(pyramidVertices)

local pyramidBase = osg.DrawElementsUShort(gldef.GL_QUADS, 0)
pyramidBase.Item:insert( osgLua.GLushort(4) )
pyramidBase.Item:insert( osgLua.GLushort(3) )
pyramidBase.Item:insert( osgLua.GLushort(2) )
pyramidBase.Item:insert( osgLua.GLushort(1) )
pyramidGeometry:addPrimitiveSet(pyramidBase)

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
pyramidGeometry:addPrimitiveSet(faces)

local colors = osg.Vec4Array()
colors.Item[1] = Vecf(1.0, 0.0, 0.0, 1.0)
colors.Item[2] = Vecf(0.0, 1.0, 0.0, 1.0)
colors.Item[3] = Vecf(1.0, 1.0, 0.0, 1.0)
colors.Item[4] = Vecf(1.0, 1.0, 1.0, 1.0)
colors.Item[5] = Vecf(0.0, 1.0, 1.0, 1.0)
colors.Item[6] = Vecf(1.0, 0.0, 1.0, 1.0)

pyramidGeometry:setColorArray(colors)
pyramidGeometry:setColorBinding(4)

RelativeTo.World:addChild(pyramidGeode)

print(RelativeTo.World:getNumChildren())