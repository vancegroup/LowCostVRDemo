require("getScriptFilename")
vrjLua.appendToModelSearchPath(getScriptFilename())

-- let require() find files in the folder that this script is located in
scriptFolder = getScriptFilename():match("(.+)[/\\].-$")   --Lua pattern, like a regex but not. Returns everything up to but not including the final slash.
if not string.find(package.path, scriptFolder) then package.path = scriptFolder .. '/?.lua;' .. package.path end

--dofile(scriptFolder .. "/controls_test.lua")

MASTER_OFFSET_VEC = {-4, -2, -10}

require "myGrabbable"
local master_xform = Transform{ position = MASTER_OFFSET_VEC }   -- control the 'world origin' for the application. The cursor starts here.
World_xform_track = osg.MatrixTransform()       -- this structure is based on the workings of myGrabbable, see notes there.
World_xform_track:addChild(master_xform)        --
World_xform_save = osg.MatrixTransform()        --
World_xform_save:addChild(World_xform_track)    --
RelativeTo.World:addChild(World_xform_save)     --
World = master_xform    -- code in this application should use this World and not RelativeTo.World

-- background (environment)
bg_model = Model("examples/models/basicfactory.ive")    -- examples/models/basicfactory.ive is built in to VR JuggLua
bg_model_orientation_xform = Transform{ position = {0, -100, 30},
                                        orientation = AngleAxis(Degrees(-100), Axis{1.0, 0.0, 0.0}),
                                        bg_model }
World:addChild(bg_model_orientation_xform)

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
		position = {0, 20, 10},
		positional = false
	}
)
World:addChild(
	Lighting{
		number = 1,
		ambient = 1.0,
		diffuse = 0.7,
		specular = 0.5,
		position = {0, 40, -10},
		positional = true
	}
)

require "runloop"
Actions.addFrameAction(runloop)
