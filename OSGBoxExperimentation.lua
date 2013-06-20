box = osg.Box(Vecf(0,0,0), 10, 10, 10)   -- gives 5 5 5
print(box.HalfLengths)
box = osg.Box(Vecf(0,0,0), 10, 10, 5)    -- gives 5 5 5
print(box.HalfLengths)
box = osg.Box(Vecf(0,0,0), 10, 5, 10)    -- gives 5 5 5
print(box.HalfLengths)
box = osg.Box(Vecf(0,0,0), 5, 10, 10)    -- gives 2.5 2.5 2.5
print(box.HalfLengths)
box = osg.Box(Vecf(0,0,0), 5, 5, 5)      -- gives 2.5 2.5 2.5
print(box.HalfLengths)
box = osg.Box(Vecf(0,0,0), 5, 10, 5)     -- gives 2.5 2.5 2.5
print(box.HalfLengths)
box = osg.Box(Vecf(0,0,0), 10, 5, 5)     -- gives 5 5 5
print(box.HalfLengths)

                                         -- Clearly, only the first input after the Vecf is being taken
                                         -- and the other two are being ignored. This means that the 
                                         -- Box(Vec3f center, float width) constructor is being called and not
                                         -- Box(Vec3f center, float lengthX, float lengthY, float lengthZ).
