require("getScriptFilename")
vrjLua.appendToModelSearchPath(getScriptFilename())

scriptFolder = getScriptFilename():match("(.+)[/\\].-$")   --Lua pattern, like a regex but not. Returns everything up to but not including the final slash.
if not string.find(package.path, scriptFolder) then package.path = scriptFolder .. '/?.lua;' .. package.path end   -- let require() find files in scriptFolder

--dofile(scriptFolder .. "/help.lua")

require "gldef"
local master_xform = Transform{ position = {0, 0, -15}  }   -- make everything happen "farther back" in the scene
RelativeTo.World:addChild(master_xform)
World = master_xform    -- code in this application should use this global World and not RelativeTo.World

-- initialize lighting
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

require "viewloop"
startViewloop()

-- view controls and object-creation/modification controls get separate FrameActions, that way you can always adjust the view while doing any other task in runloop
require "runloop"
Actions.addFrameAction(runloop)
