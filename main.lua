require("getScriptFilename")
vrjLua.appendToModelSearchPath(getScriptFilename())

scriptFolder = getScriptFilename():match("(.+)[/\\].-$")   --Lua pattern, like a regex but not. Returns everything up to but not including the final slash.
if not string.find(package.path, scriptFolder) then package.path = scriptFolder .. '/?.lua;' .. package.path end   -- let require() find files in scriptFolder

--dofile(scriptFolder .. "/help.lua")

local master_xform = Transform{ position = {0, 0, -5}  }   -- make everything happen "farther back" in the scene
RelativeTo.World:addChild(master_xform)
World = master_xform    -- code in this application should use this global World and not RelativeTo.World

require "runloop"
Actions.addFrameAction(runloop)
