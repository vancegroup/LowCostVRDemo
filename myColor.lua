--[[
    class myColor = {}
        Constructor: myColor(image, vec, colorname)  -- accepts a Geode or Transform etc.; returns a Grabbable based on it
        
        .attach_here   -- since I don't know how to properly inherit from Transform or Node (which myGrabbable should be a subclass of), instead we have this
                       -- .attach_here field. When you have a grabbable, the grabbable.attach_here is what you should add as a child of a Transform or World etc.
        
        -- private members
        .frameaction  -- the handle to its FrameAction (see Actions.lua) if it is currently grabbed
]]--

function myColor(image, vec, colorname)
	color = {}
	color.image = image
	color.vec = vec
	color.name = colorname
	return color
end















