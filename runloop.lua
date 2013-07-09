require "controls"
require "cursor"
require "library"
--require "ShapeObjects.include_all"   -- alternate (old) implementations for Box, Cone, Cylinder, and Sphere
require "GeometryObjects.include_all"

-- only for sim mode testing
require "controls_sim_mode"

objects = {}  -- list of all myObjects that have been created (numerically indexed)

function runloop()
    local cursor = Cursor()  -- initialize the cursor
    
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
                startLoc = Vecf(wand.position)
                object.initialDistFromCenter = (startLoc - object:getCenterInWorldCoords()):length()
                object:initializeScaling()
            end
            
            -- perform the operation while the button is held down
            repeat
                
                local endLoc = Vecf(wand.position)
                
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