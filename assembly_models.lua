require "myGrabbable"

device = gadget.PositionInterface("VJWand")
selectButton = gadget.DigitalInterface("VJButton1")

part_1 = myGrabbable(Model("sparta_models/Clutch-FlywheelPart1.ive"), device)
part_2 = myGrabbable(Model("sparta_models/Clutch-FlywheelPart2.ive"), device)
part_3 = myGrabbable(Model("sparta_models/Clutch-FlywheelPart3.ive"), device)
part_4 = myGrabbable(Model("sparta_models/Clutch-FlywheelPart4.ive"), device)

RelativeTo.World:addChild(part_1.attach_here)
RelativeTo.World:addChild(part_2.attach_here)
RelativeTo.World:addChild(part_3.attach_here)
RelativeTo.World:addChild(part_4.attach_here)

Actions.addFrameAction(function()
	
	while true do
		
		grab(part_1)
		print("Part 1 is selected.")
		
		repeat
			Actions.waitForRedraw()
		until selectButton.justPressed
		
		ungrab(part_1)
		grab(part_2)
		print("Part 2 is selected.")
		
		repeat
			Actions.waitForRedraw()
		until selectButton.justPressed
		
		ungrab(part_2)
		grab(part_3)
		print("Part 3 is selected.")
		
		repeat
			Actions.waitForRedraw()
		until selectButton.justPressed
		
		ungrab(part_3)
		grab(part_4)
		print("Part 4 is selected.")
		
		repeat
			Actions.waitForRedraw()
		until selectButton.justPressed
		
		ungrab(part_4)
		
	end
end)
