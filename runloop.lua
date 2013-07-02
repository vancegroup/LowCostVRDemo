require "controls"
require "cursor"
require "library"
require "Box"
require "Cone"
require "Cylinder"
require "Sphere"

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
                o.selected = false  -- deselect all other objects when creating a new one. Assuming this is desired behavior.
            end
            
            shape, color = libraryCalled()
            
            if string.find(shape, "cube") then
                table.insert(objects, Box())
            elseif string.find(shape, "cone") then
                table.insert(objects, Cone())
            elseif string.find(shape, "cylinder") then
                table.insert(objects, Cylinder())
            elseif string.find(shape, "pyramid") then
                print("Sorry, pyramid not supported yet.")
            elseif string.find(shape, "sphere") then
                table.insert(objects, Sphere())
            else
                print("Unrecognized return value from libraryCalled(): ", shape)
            end
        
        elseif click_to_select_button.justPressed then 
            
            local cursorOverAnything = false
            for _, o in ipairs(objects) do
                if o.cursorOver then
                    cursorOverAnything = true
                    if o.selected then 
                        o.selected = false
                        ungrab(o)
                    else
                        o.selected = true
                        grab(o)
                    end
                end
            end
            
            if not cursorOverAnything then
                for _, o in ipairs(objects) do
                    if o.selected then
                        o.selected = false
                        ungrab(o)
                    end
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
                elseif object.osgsphere then
                    newObject = Sphere(object)
                else 
                    print("Error: unsupported object for duplicate")
                end
                table.insert(objects, newObject)
                object.selected = false  -- deselect the old (parent) object
                ungrab(object)
                newObject.selected = true  -- select the new (copy) object
                grab(newObject)
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
