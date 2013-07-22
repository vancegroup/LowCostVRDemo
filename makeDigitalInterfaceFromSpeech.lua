-- makes a voice input act like a gadget.DigitalInterface
-- voice: (gadget.StringInterface) the voice input to convert
-- text: (string) the string to listen for
-- name: (string) the DigitalInterface will be available on a global variable with this name
-- hold: (Lua bool) If true, the button will remain pressed after the speech is detected, until the text "stop" is detected. If false, the button will be pressed down for only one frame.

function makeDigitalInterfaceFromSpeech(voice, text, name, hold)
    _G[name] = {}
	if hold then
		Actions.addFrameAction(function()  
			while true do
				-- just released
				_G[name].justReleased = true
				_G[name].justChanged = true
				_G[name].pressed = false
				Actions.waitForRedraw()
				
				-- released but not just released (since last frame)
				_G[name].justReleased = false
				_G[name].justChanged = false
				repeat
					Actions.waitForRedraw()
				until voice.data == text
				
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
				until voice.data == stop
			end
		end)
	else
		Actions.addFrameAction(function()
			while true do
				-- just released
				_G[name].justPressed = false
				_G[name].justReleased = true
				_G[name].justChanged = true
				_G[name].pressed = false
				Actions.waitForRedraw()
				
				-- released but not just released (since last frame)
				_G[name].justReleased = false
				_G[name].justChanged = false
				repeat
					Actions.waitForRedraw()
				until voice.data == text
				
				-- just pressed
				_G[name].justPressed = true
				_G[name].justChanged = true
				_G[name].pressed = true
				-- wait one frame - during this frame the button is pressed
				Actions.waitForRedraw()
			end
		end)
	end
end