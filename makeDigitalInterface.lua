-- makes an analog input act like a gadget.DigitalInterface
-- analog: (gadget.AnalogInterface) the analog input to convert
-- name: (string) the DigitalInterface will be available on a global variable with this name
-- dir: 1 if input above 0.5 should be considered pressed, 0 if input below 0.5 should be considered pressed
--         (note that 0.5 is considered released in either case)
function makeDigitalInterface(analog, name, dir)
    _G[name] = {}
    if dir == 0 then
        Actions.addFrameAction(function()  
            while true do
                -- just released
                _G[name].justReleased = true
                _G[name].justChanged = true
                _G[name].pressed = false
                Actions.waitForRedraw()
                -- during this frame the just* will be true for everyone else
                Actions.waitForRedraw()
                
                -- released but not just released (since last frame)
                _G[name].justReleased = false
                _G[name].justChanged = false
                repeat
                    Actions.waitForRedraw()
                until analog.data < 0.25
                
                -- just pressed
                _G[name].justPressed = true
                _G[name].justChanged = true
                _G[name].pressed = true
                Actions.waitForRedraw()
                
                -- pressed but not just pressed (since last frame)
                _G[name].justPressed = false
                _G[name].justChanged = false
                repeat
                    Actions.waitForRedraw()
                until analog.data == 0.5
            end
        end)
    else
        Actions.addFrameAction(function()  
            while true do
                -- just released
                _G[name].justReleased = true
                _G[name].justChanged = true
                _G[name].pressed = false
                Actions.waitForRedraw()
                -- during this frame the just* will be true for everyone else
                Actions.waitForRedraw()
                
                -- released but not just released (since last frame)
                _G[name].justReleased = false
                _G[name].justChanged = false
                repeat
                    Actions.waitForRedraw()
                until analog.data > 0.75
                
                -- just pressed
                _G[name].justPressed = true
                _G[name].justChanged = true
                _G[name].pressed = true
                Actions.waitForRedraw()
                
                -- pressed but not just pressed (since last frame)
                _G[name].justPressed = false
                _G[name].justChanged = false
                repeat
                    Actions.waitForRedraw()
                until analog.data == 0.5
            end
        end)
    end
end