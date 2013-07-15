require "controls"

osgnav.removeStandardNavigation()

local loop;

function startViewloop()
    loop = Actions.addFrameAction(viewloop)
end

function stopViewloop()
    if loop then Actions.removeFrameAction(loop) end
end

function viewloop()
    while true do
    
        if hold_to_zoom_in_button.justPressed then
            repeat
                RelativeTo.World:postMult(osg.Matrixd.translate(0,0,-0.2))
                Actions.waitForRedraw()
            until not hold_to_zoom_in_button.pressed
        elseif hold_to_zoom_out_button.justPressed then
            repeat
                RelativeTo.World:postMult(osg.Matrixd.translate(0,0,0.2))
                Actions.waitForRedraw()
            until not hold_to_zoom_out_button.pressed
        end
        
        Actions.waitForRedraw()
    
    end
end

Actions.addFrameAction(function()
    while true do
        print(RelativeTo.World.Matrix:getTrans())
        Actions.waitForRedraw()
    end
end)
