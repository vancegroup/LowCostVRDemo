device = gadget.PositionInterface('VJWand')
button0 = gadget.DigitalInterface('VJButton0')
button1 = gadget.DigitalInterface('VJButton1')
button2 = gadget.DigitalInterface('VJButton2')
button3 = gadget.DigitalInterface('VJButton3')
button4 = gadget.DigitalInterface('VJButton4')
trigger = button2  -- for now
bumper = button1  -- for now
stickclick = button0  -- for now
analogstick = nil

-- aliases, all other routines use only these aliases. Thus, you can change any of the controls only by changing these assignments.
wand = device
open_library_button = button1
hold_to_draw_button = trigger
hold_to_stretch_button = bumper
hold_to_scale_button = trigger
hold_to_slice_button = button3
hold_to_adjust_view_button = button0
click_to_select_button = stickclick
click_to_deselect_button = stickclick
click_to_drag_select_button = stickclick
click_to_duplicate_button = button2
click_to_delete_button = button4
allbuttons = {button0, button1, button2, button3, button4, trigger, bumper, stickclick}