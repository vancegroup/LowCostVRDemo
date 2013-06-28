require "controls"

Actions.addFrameAction(function()
    while true do
        for _, b in ipairs(allbuttons) do
            if b.justPressed then 
                if button0.justPressed then print("Button 0") end
                if button1.justPressed then print("Button 1") end
                if button2.justPressed then print("Button 2") end
                if button3.justPressed then print("Button 3") end
                if button4.justPressed then print("Button 4") end
                if bumper.justPressed then print("Bumper") end
                if stickclick.justPressed then print("Stick click") end
                if trigger.justPressed then print("Trigger") end
                if stickXLeft.justPressed then print("Stick left") end
                if stickXRight.justPressed then print("Stick right") end
                if stickYUp.justPressed then print("Stick up") end
                if stickYDown.justPressed then print("Stick down") end
                Actions.waitForRedraw(30)
            end
        end
        print("Analog X: ", analogstickX.data)
        print("Analog Y: ", analogstickY.data)
        Actions.waitForRedraw()
    end
end)
