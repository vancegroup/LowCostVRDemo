require "controls"
require "cursor"
require "library"
--require "ShapeObjects.include_all"   -- alternate (old) implementations for Box, Cone, Cylinder, and Sphere
require "GeometryObjects.include_all"

-- only for sim mode testing
--require "controls_sim_mode"

objects = {}  -- list of all myObjects that have been created (numerically indexed)

function runloop()
    cursor = Cursor()  -- initialize the cursor, globally accessible
    
    while true do
        
        for _, o in ipairs(objects) do
            if o:contains(cursor:getPosition()) then
                o.cursorOver = true
                if not o.selected then o:makeSemiTransparent() end
            else
                o.cursorOver = false
                if not o.selected then o:makeUnTransparent() end
            end
        end
        
        if open_library_button.justPressed then
            
            for _, o in ipairs(objects) do
                o:deselect()  -- deselect all other objects when creating a new one. Assuming this is desired behavior.
            end
            
            shape, color = libraryCalled()
            
            if shape == nil then
                print("Menu was closed without selecting anything.")
            else
            
                if string.find(shape, "cube") then
                    table.insert(objects, Box(color))
                elseif string.find(shape, "cone") then
                    table.insert(objects, Cone(color))
                elseif string.find(shape, "cylinder") then
                    table.insert(objects, Cylinder(color))
                elseif string.find(shape, "pyramid") then
                    table.insert(objects, Pyramid(color))
                elseif string.find(shape, "sphere") then
                    table.insert(objects, Sphere(color))
                else
                    print("Unrecognized return value from libraryCalled(): ", shape)
                end
                
            end
        
        elseif click_to_select_button.justPressed then 
            
            local cursorOverAnything = false
            for _, o in ipairs(objects) do
                if o.cursorOver then
                    cursorOverAnything = true
                    if o.selected then 
                        o:deselect()
                    else
                        o:select()
                    end
                end
            end
            
            if not cursorOverAnything then
                for _, o in ipairs(objects) do
                    o:deselect()
                end
            end
        
        elseif hold_to_scale_button.justPressed then
        
            -- make a list of all selected objects
            local selectedObjects = {}
            for _, object in ipairs(objects) do
                if object.selected then table.insert(selectedObjects, object) end
            end
            
            -- initialize all selected objects for the operation
            local startLoc;
            for _, object in ipairs(selectedObjects) do
                ungrab(object)  -- keep objects locked in place during scaling
                object:openForEditing()
                startLoc = Vecf(cursor:getPosition())
                object.initialDistFromCenter = (startLoc - object:getCenterInWorldCoords()):length()
                object:initializeScaling()
            end
            
            -- perform the operation while the button is held down
            repeat
                
                local endLoc = Vecf(cursor:getPosition())
                
                for _, object in ipairs(selectedObjects) do
                    object.newDistFromCenter = (endLoc - object:getCenterInWorldCoords()):length()
                    local newScale = 1.0 + (object.newDistFromCenter-object.initialDistFromCenter)/object.initialDistFromCenter  -- moving the wand twice as far from the center as when you started scaling will double the object's size. Moving it all the way to the center of the object will make its size 0 (in the limit).
                    object:scale(newScale)
                end
            
                Actions.waitForRedraw()   -- all other commands are put on hold until the scale button is released (including changing selection, etc)
            
            until not hold_to_scale_button.pressed
            
            -- finalize editing for all selected objects
            for _, object in ipairs(selectedObjects) do
                object:closeForEditing()
                grab(object)  -- because we ungrabbed them during initialization of the operation
            end
        
        elseif hold_to_stretch_button.justPressed then
            
            -- make a list of all selected objects
            local selectedObjects = {}
            for _, object in ipairs(objects) do
                if object.selected then 
                    if object.geometry then
                        table.insert(selectedObjects, object)
                    else
                        print("Error: ShapeObjects cannot be stretched")
                    end
                end
            end
            
            if next(selectedObjects) ~= nil then   -- makes sure table is not empty
            
                -- initialize all selected objects for the operation
                local startLoc;
                for _, object in ipairs(selectedObjects) do
                    ungrab(object)  -- keep objects locked in place during scaling
                    object:openForEditing()
                    startLoc = Vecf(cursor:getPosition())
                    object.initialDistFromCenter = (startLoc - object:getCenterInWorldCoords()):length()
                    print("Cursor position reported as ", startLoc)
                    print("Object center in world coords is ", object:getCenterInWorldCoords())
                    print("initialDistFromCenter = ", object.initialDistFromCenter)
                    object:initializeScaling()
                end
                
                -- determine which axis the user intends to scale along
                local DETERMINATION_THRESHOLD = 0.2   -- once the wand is moved this distance along any axis after the stretch button is pressed, that axis is considered chosen
                local axis = nil
                local done = false
                startLoc = Vecf(cursor:getPosition())
                repeat
                
                    local endLoc = Vecf(cursor:getPosition())
                    deltax, deltay, deltaz = getDeltas(startLoc, endLoc)
                    if math.abs(deltax) > DETERMINATION_THRESHOLD then
                        axis = 'x'
                        done = true
                    elseif math.abs(deltay) > DETERMINATION_THRESHOLD then
                        axis = 'y'
                        done = true
                    elseif math.abs(deltaz) > DETERMINATION_THRESHOLD then
                        axis = 'z'
                        done = true
                    end
                    
                    Actions.waitForRedraw()
                    
                until done or not hold_to_stretch_button.pressed
                
                if axis then    -- if the hold_to_stretch_button was released before axis determination was made, then axis will still be nil.
                    
                    print("Determined to stretch along the ", axis, " axis.")
                    
                    -- perform the operation while the button is held down
                    repeat
                        
                        local endLoc = Vecf(cursor:getPosition())
                        
                        for _, object in ipairs(selectedObjects) do
                            object.newDistFromCenter = (endLoc - object:getCenterInWorldCoords()):length()
                            local newScale = 1.0 + (object.newDistFromCenter-object.initialDistFromCenter)/object.initialDistFromCenter  -- scaling is still based on the distance from the object's center in all 3 dimensions, even though changes only happen in 1 dimension. The dimension it happens along was determined by where the wand was moved first; after that movement in any direction changes the scaling. This way the controls seem responsive.
                            object:stretch(newScale, axis)
                        end
                    
                        Actions.waitForRedraw()   -- all other commands are put on hold until the stretch button is released (including changing selection, etc)
                    
                    until not hold_to_stretch_button.pressed
                    
                    -- finalize editing for all selected objects
                    for _, object in ipairs(selectedObjects) do
                        object:closeForEditing()
                        grab(object)  -- because we ungrabbed them during initialization of the operation
                    end
                
                end
                
            end
            
        elseif click_to_duplicate_button.justPressed then
            
            local selectedObjects = {}
            for _, object in ipairs(objects) do
                if object.selected then table.insert(selectedObjects, object) end
            end
            
            for _, object in ipairs(selectedObjects) do
                local newObject = nil
                if object.osgbox then
                    newObject = Box(object)
                elseif object.osgcone then
                    newObject = Cone(object)
                elseif object.osgcylinder then
                    newObject = Cylinder(object)
                elseif object.geometry then
                    newObject = Pyramid(object)   -- assume all PrimitiveSet objects are pyramids, for now
                elseif object.osgsphere then
                    newObject = Sphere(object)
                else 
                    print("Error: unsupported object for duplicate")
                end
                table.insert(objects, newObject)
                object:deselect()  -- deselect the old (parent) object
                newObject:select()  -- select the new (copy) object
            end
        
        elseif click_to_delete_button.justPressed then
            
            for index = #objects, 1, -1 do  -- iterate backwards through objects, this makes table.remove safe
                local object = objects[index]
                if object.selected then
                    object:removeObject()
                    table.remove(objects, index)
                end
            end
        
        end
        
        Actions.waitForRedraw()
        
    end
end
