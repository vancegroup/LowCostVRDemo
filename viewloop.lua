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
            pauseSelection()
            grab(WorldGrabbable)
            repeat
                viewloop_waitForRedraw()
            until not hold_to_adjust_view_button.pressed
            ungrab(WorldGrabbable)
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
