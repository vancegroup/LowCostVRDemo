require "makeDigitalInterfaceFromSpeech"

local kinect_speech = gadget.StringInterface("KinectProxy")

makeDigitalInterfaceFromSpeech(kinect_speech, "menu", say_menu, false)
makeDigitalInterfaceFromSpeech(kinect_speech, "draw", say_draw, true)
makeDigitalInterfaceFromSpeech(kinect_speech, "right", say_right, false)
makeDigitalInterfaceFromSpeech(kinect_speech, "left", say_left, false)
makeDigitalInterfaceFromSpeech(kinect_speech, "up", say_up, false)
makeDigitalInterfaceFromSpeech(kinect_speech, "down", say_down, false)
makeDigitalInterfaceFromSpeech(kinect_speech, "select", say_select, false)
makeDigitalInterfaceFromSpeech(kinect_speech, "scale", say_scale, true)
makeDigitalInterfaceFromSpeech(kinect_speech, "stretch", say_stretch, true)
makeDigitalInterfaceFromSpeech(kinect_speech, "duplicate", say_duplicate, false)
makeDigitalInterfaceFromSpeech(kinect_speech, "delete", say_delete, false)
makeDigitalInterfaceFromSpeech(kinect_speech, "in", say_in, true)
makeDigitalInterfaceFromSpeech(kinect_speech, "out", say_out, true)
makeDigitalInterfaceFromSpeech(kinect_speech, "view", say_view, true)

wand = nil
open_library_button = say_menu
hold_to_draw_button = say_draw
hold_to_stretch_button = say_stretch
hold_to_scale_button = say_scale
hold_to_zoom_in_button = say_in
hold_to_zoom_out_button = say_out
hold_to_adjust_view_button = say_view
click_to_select_button = say_select
click_to_duplicate_button = say_duplicate
click_to_delete_button = say_delete
library_scroll_left_button = say_left
library_scroll_right_button = say_right
library_switch_up_button = say_up
library_switch_down_button = say_down
library_confirm_button = say_select