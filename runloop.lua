require "controls"
require "drawCylinder"
require "cursor"

--[[
    abstract base class myObject: inherits from myGrabbable -- that is, it must be first initialized with the myGrabbable constructor
        (Lua)bool .selected   -- whether object is selected or not
        (Lua)bool .cursorOver   -- whether the cursor is over the object or not
        Vec3f :getCenter()
        void :initializeScaling()  -- get ready for subsequent calls to scale()
        void :scale(float)
        void :openForEditing()
        void :closeForEditing()
        (Lua)bool :contains(Vec3f)   -- whether the object contains the point passed as argument
]]--

objects = {}  -- list of all myObjects that have been created (numerically indexed)

function runloop()
    cursor = Cursor()  -- initialize the cursor
    
    while true do
        repeat
            print("World cursor coordinates reported as "); printVec(cursor:getPosition())
            for _, o in ipairs(objects) do
                if o:contains(cursor:getPosition()) then
                    o.cursorOver = true
                    if not o.selected then o:makeSemiTransparent() end
                else
                    o.cursorOver = false
                    if not o.selected then o:makeUnTransparent() end
                end
            end
            Actions.waitForRedraw()
        until somethingHappens()
        
        if open_library_button.pressed then
            
            for _, o in ipairs(objects) do
                o.selected = false  -- deselect all other objects when creating a new one. Assuming this is desired behavior.
            end
            table.insert(objects, Cylinder())
        
        elseif click_to_select_button.pressed then 
            
            for _, o in ipairs(objects) do
                if o.cursorOver then
                    if o.selected then 
                        o.selected = false
                        ungrab(o)
                    else
                        o.selected = true
                        grab(o)
                    end
                end
            end
        
        elseif hold_to_scale_button.pressed then
            
            -- make a list of all selected objects
            local selectedObjects = {}
            for _, object in ipairs(objects) do
                if object.selected then table.insert(selectedObjects, object) end
            end
            
            -- initialize all selected objects for the operation
            for _, object in ipairs(selectedObjects) do
                ungrab(object)  -- keep objects locked in place during scaling
                object:openForEditing()
                local startLoc = Vecf(wand.position)
                local initialDistFromCenter = (startLoc - object:getCenter()):length()
                object:initializeScaling()
            end
            
            -- perform the operation while the button is held down
            repeat
                
                local endLoc = Vecf(wand.position)
                
                for _, object in ipairs(selectedObjects) do
                    local newDistFromCenter = (endLoc - object:getCenter()):length()
                    local newScale = 1.0 + (newDistFromCenter-initialDistFromCenter)/initialDistFromCenter  -- moving the wand twice as far from the center as when you started scaling will double the object's size. Moving it all the way to the center of the object will make its size 0 (in the limit).
                    object:scale(newScale)
                end
            
                Actions.waitForRedraw()   -- all other commands are put on hold until the scale button is released (including changing selection, etc)
            
            until not hold_to_scale_button.pressed
            
            -- finalize editing for all selected objects
            for _, object in ipairs(selectedObjects) do
                object:closeForEditing()
                grab(object)  -- because we ungrabbed them during initialization of the operation
            end
            
        end
        
        repeat
            Actions.waitForRedraw()
        until not somethingHappens()  -- avoid multiple presses
        
    end
end

function somethingHappens()
    for _, b in ipairs(allbuttons) do
        if b.pressed then return b end
    end
    return nil
end
