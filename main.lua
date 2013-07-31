require "AddAppDirectory"
AddAppDirectory()

-- let require() find files in the folder that this script is located in
scriptFolder = getScriptFilename():match("(.+)[/\\].-$")   --Lua pattern, like a regex but not. Returns everything up to but not including the final slash.
if not string.find(package.path, scriptFolder) then package.path = scriptFolder .. '/?.lua;' .. package.path end

--dofile(scriptFolder .. "/controls_test.lua")

World = MatrixTransform{}   -- code in this application should use this World and not RelativeTo.World
World_xform_track = MatrixTransform{        -- this structure is based on the workings of myGrabbable, see notes there.
    World
}
World_xform_save = MatrixTransform{         --
    World_xform_track
}
RelativeTo.World:addChild(World_xform_save) --

-- background (environment)
 -- examples/models/basicfactory.ive is built in to VR JuggLua
World:addChild(
    Transform{
        position = {0, -150, 30},
        orientation = AngleAxis(Degrees(-100), Axis{1.0, 0.0, 0.0}),
        Model("examples/models/basicfactory.ive")
    }
)

-- initialize lighting

-- Pass in a table with "num", "stateset", and optionally "ambient", "diffuse", "specular", and "mode" (either 1 or 0)
-- Returns the LightSource - position appropriately.
local makeLight = function(arg)
    local light = osg.Light(arg.num)
    if arg.ambient then light:setAmbient(arg.ambient) end
    if arg.diffuse then light:setDiffuse(arg.diffuse) end
    if arg.specular then light:setSpecular(arg.specular) end
    if arg.mode then light:setPosition(osg.Vec4(0, 0, 0, arg.mode)) end
    local lightsource = osg.LightSource()
    lightsource:setLight(light)
    -- Think this is redundant or a nop
    --lightsource:setLocalStateSetModes(osg.StateAttribute.Values.ON)
    arg.stateset:setAssociatedModes(light, osg.StateAttribute.Values.ON)
    return lightsource
end

RelativeTo.Room:addChild(
    Group{
        Transform{
            position = {-1, 0, 2};
            makeLight{
                num = 3;
                ambient = osg.Vec4(.2, .2, .2, 1.0);
                diffuse = osg.Vec4(.8, .8, .8, 1.0);
                mode = 1;
                stateset = GlobalStateSet;
            }
        };
        Transform{
            position = {1, 4, 6};
            makeLight{
                num = 2;
                ambient = osg.Vec4(.3, .3, .3, .50);
                diffuse = osg.Vec4(1, 1, 1, .50);
                mode = 1;
                stateset = GlobalStateSet;
            }
        };
    }
)

require "runloop"
Actions.addFrameAction(runloop)
