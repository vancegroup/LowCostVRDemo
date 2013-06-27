require("getScriptFilename")
vrjLua.appendToModelSearchPath(getScriptFilename())

scriptFolder = getScriptFilename():match("(.+)/.-$")   --Lua pattern, like a regex but not. Returns everything up to but not including the final slash.
if not string.find(package.path, scriptFolder) then package.path = scriptFolder .. '/?.lua;' .. package.path end   -- let require() find files in scriptFolder

--dofile(scriptFolder .. "/assembly_models.lua")

require "runloop"
Actions.addFrameAction(runloop)