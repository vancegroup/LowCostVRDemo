-- Redefines the controls aliases for use in sim mode. See controls.lua.
-- Note: in sim mode, button0 is the left mouse button, button1 is the middle button, and button2 is the right mouse button. Moving the wand can be acheived by holding ctrl and moving the mouse (xy-translation), holding alt and moving the mouse (z-translation), and/or holding shift and moving the mouse (rotation).

notAvailable = {pressed = false; justPressed = false; justReleased = false; justChanged = false}

wand = device
open_library_button = button1
hold_to_draw_button = button2
hold_to_stretch_button = notAvailable
hold_to_scale_button = button2
hold_to_slice_button = notAvailable
hold_to_zoom_in_button = notAvailable
hold_to_zoom_out_button = notAvailable
hold_to_adjust_view_button = button1
click_to_select_button = button0
click_to_duplicate_button = button1
click_to_delete_button = notAvailable
library_scroll_left_button = notAvailable
library_scroll_right_button = button2
library_switch_up_button = notAvailable
library_switch_down_button = button1
library_confirm_button = button0