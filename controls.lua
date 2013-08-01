require "makeDigitalInterface"

device = gadget.PositionInterface('VJWand')
button0 = gadget.DigitalInterface('VJButton0')
button1 = gadget.DigitalInterface('VJButton1')
button2 = gadget.DigitalInterface('VJButton2')
button3 = gadget.DigitalInterface('VJButton3')
button4 = gadget.DigitalInterface('VJButton4')
trigger_analog = gadget.AnalogInterface('Trigger')
bumper = gadget.DigitalInterface('Bumper')
stickclick = gadget.DigitalInterface('StickButton')
analogstickX = gadget.AnalogInterface('StickX')
analogstickY = gadget.AnalogInterface('StickY')

makeDigitalInterface(trigger_analog, "trigger", 1)
makeDigitalInterface(analogstickX, "stickXLeft", 0)
makeDigitalInterface(analogstickX, "stickXRight", 1)
makeDigitalInterface(analogstickY, "stickYUp", 1)
makeDigitalInterface(analogstickY, "stickYDown", 0)
-- you can use trigger, stickXLeft, stickXRight, stickYUp, and stickYDown as DigitalInterfaces (i.e. buttons).


-- this function is necessary to correct for a bug with either VRPN/Juggler or the Hydra hardware.
--      the bug goes as follows:
--      The normal "neutral" position of all AnalogInterfaces is defined to be 0.5, with a min of 0 and a max of 1.
--      When the application is started, however, the y-direction on the hydra stick will report 0 instead of 0.5, despite being in the neutral position.
--      This continues until the stick is moved at all in either the up or down direction. Once any movement is made to the stick, it snaps out of it and reports correct measurements for the rest of the life of the program.
--      With the current controls configuration, this causes a large amount of zooming out upon program start, or the user always having to quickly bump the Hydra stick immediately after the application is started (the sooner the better).
--      To avoid this issue, we have this function.
Actions.addFrameAction(function()
    repeat
        stickYDown.pressed = false
        stickYDown.justPressed = false
        stickYDown.justReleased = false
        stickYDown.justChanged = false
        Actions.waitForRedraw()
    until analogstickY.data > 0.25
end)

-- aliases, all other routines use only these aliases. Thus, you can change any of the controls only by changing these assignments.
wand = device
open_library_button = button1
hold_to_draw_button = trigger
hold_to_stretch_button = bumper
hold_to_scale_button = trigger
hold_to_zoom_in_button = stickYUp
hold_to_zoom_out_button = stickYDown
hold_to_adjust_view_button = button0
click_to_select_button = stickclick
click_to_duplicate_button = button2
click_to_delete_button = button4
library_scroll_left_button = stickXLeft
library_scroll_right_button = stickXRight
library_switch_up_button = stickYUp
library_switch_down_button = stickYDown
library_confirm_button = stickclick
help_button = button3
allbuttons = {button0, button1, button2, button3, button4, bumper, stickclick, trigger, stickXLeft, stickXRight, stickYUp, stickYDown}
allanalogs = {trigger_analog, analogstickX, analogstickY}
