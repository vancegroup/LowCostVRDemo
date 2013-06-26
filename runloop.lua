require "controls"
require "drawCylinder"
require "cursor"

--[[
    abstract base class myObject: inherits from myGrabbable -- that is, it must be first initialized with the myGrabbable constructor
        (Lua)bool .selected   -- whether object is selected or not
        Vec3f :getCenter()
        void :initializeScaling()  -- get ready for subsequent calls to scale()
        void :scale(newScale)
        void :openForEditing()
        void :closeForEditing()
]]--

objects = {}  -- list of all myObjects that have been created (numerically indexed)

function runloop()
    while true do
        repeat
            Actions.waitForRedraw()
        until somethingHappens()
        
        if open_library_button.pressed then
            
            table.insert(objects, createCylinder())
        
        elseif click_to_select_button.pressed then  -- TODO select objects other than the first created
            
            if objects[1].selected then
                objects[1].selected = false
                ungrab(objects[1])
            else
                objects[1].selected = true
                grab(objects[1])
            end
        
        elseif hold_to_scale_button.pressed then
            
            local object = nil
            for _, o in ipairs(objects) do
                if o.selected then object = o; break end   -- TODO behave properly when multiple objects selected
            end
            
            if object then  -- something is selected
            
                object:openForEditing()
                local startLoc = Vecf(wand.position)
                local initialDistFromCenter = (startLoc - object:getCenter()):length()
                object:initializeScaling()
                
                repeat
                    local endLoc = Vecf(wand.position)
                    local newDistFromCenter = (endLoc - object:getCenter()):length()
                    local newScale = 1.0 + (newDistFromCenter-initialDistFromCenter)/initialDistFromCenter  -- moving the wand twice as far from the center as when you started scaling will double the object's size. Moving it all the way to the center of the object will make its size 0 (in the limit).
                    object:scale(newScale)
                    Actions.waitForRedraw()   -- all other commands are put on hold until the scale button is released (including changing selection, etc)
                until not hold_to_scale_button.pressed
                
                object:closeForEditing()
                
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
