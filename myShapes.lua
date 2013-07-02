--[[
    class shape = {}
        Constructor: shape(image, pos)  -- accepts a Geode or Transform etc.; returns a Grabbable based on it
        
        .attach_here   -- since I don't know how to properly inherit from Transform or Node (which myGrabbable should be a subclass of), instead we have this
                       -- .attach_here field. When you have a grabbable, the grabbable.attach_here is what you should add as a child of a Transform or RelativeTo.World etc.
        
        -- private members
		.shapename -- name of shape
]]--

function myShapes(image, name)
	shape = {}
	shape.image = image
	shape.name = name
	return shape
end
