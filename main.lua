require("getScriptFilename")
vrjLua.appendToModelSearchPath(getScriptFilename())

-- let require() find files in the folder that this script is located in
scriptFolder = getScriptFilename():match("(.+)[/\\].-$")   --Lua pattern, like a regex but not. Returns everything up to but not including the final slash.
if not string.find(package.path, scriptFolder) then package.path = scriptFolder .. '/?.lua;' .. package.path end

--dofile(scriptFolder .. "/help.lua")

MASTER_OFFSET_VEC = {0, 0, -10}

require "myGrabbable"
local master_xform = Transform{ position = MASTER_OFFSET_VEC }   -- make everything happen "farther back" in the scene
WorldGrabbable = myGrabbable(master_xform)
RelativeTo.World:addChild(WorldGrabbable.attach_here)
World = master_xform    -- code in this application should use this World and not RelativeTo.World

-- initialize lighting
require "gldef"
World:getOrCreateStateSet():setMode(gldef.GL_LIGHTING, osg.StateAttribute.Values.ON)   -- turn lighting on
RelativeTo.Room:getOrCreateStateSet():setMode(gldef.GL_LIGHTING, osg.StateAttribute.Values.OFF)   -- disable lighting on room objects (i.e. the menu)
World:addChild(
	Lighting{
		number = 0,
		ambient = 1.0,
		diffuse = 0.7,
		specular = 0.5,
		position = {0, 4, 2},
		positional = false
	}
)
World:addChild(
	Lighting{
		number = 1,
		ambient = 1.0,
		diffuse = 0.7,
		specular = 0.5,
		position = {0, 8, 2},
		positional = true
	}
)

require "runloop"
Actions.addFrameAction(runloop)
