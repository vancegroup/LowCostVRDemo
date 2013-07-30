require "controls"
require "myGrabbable"
require "runloop"   -- pauseSelection() etc

osgnav.removeStandardNavigation()

local viewloopPaused = false

function pauseViewloop()
    viewloopPaused = true
end

function resumeViewloop()
    viewloopPaused = false
end

function viewloop()
    while true do
    
        if hold_to_adjust_view_button.justPressed then
     
            pauseSelection()  -- a runloop.lua function
            
            cacheViewCoords()   -- cache the current view coords so that controls are taken relative to this view until you're done changing the view
            
            -- resembles myGrabbable's 'grab' (see comments there), but without the transparency and with the WandMatrix calls inverted. The inversion makes it seem like you're grabbing the camera rather than the world
            World_xform_save:preMult(getCursorPoseInViewCoords())
            World_xform_track:setMatrix(osg.Matrixd.inverse(getCursorPoseInViewCoords()))
            frameaction = Actions.addFrameAction(function()
                while true do
                    World_xform_track:setMatrix(osg.Matrixd.inverse(getCursorPoseInViewCoords()))
                    Actions.waitForRedraw()
                end
            end)
            
            repeat
                viewloop_waitForRedraw()
            until not hold_to_adjust_view_button.pressed
            
            -- resembles myGrabbable's 'ungrab', but with the same modifications described above
            Actions.removeFrameAction(frameaction)
            World_xform_save:preMult(osg.Matrixd.inverse(getCursorPoseInViewCoords()))
            World_xform_track:setMatrix(osg.Matrixd.identity())
            
            resumeSelection()
            
        end
        
        viewloop_waitForRedraw()
    
    end
end

function viewloop_waitForRedraw()
    repeat
        Actions.waitForRedraw()
    until not viewloopPaused   -- this loop structure guarantees at least one call to Actions.waitForRedraw()
end

local cachedViewCoords = nil

function cacheViewCoords()
    cachedViewCoords = osg.Matrixd.inverse(World_xform_save.Matrix)
end

function getCursorPoseInViewCoords()
    return cursor:getPose() * cachedViewCoords   -- using the new * for matrix multiplication in JuggLua
end
