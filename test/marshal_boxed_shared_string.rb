# Marshal.dump of a String a box holds as its shared handle (a String both
# aliased and changed in place, read into an untyped variable or a mixed
# Array) writes the String's current bytes, as CRuby does. It raised
# TypeError ("no marshal_dump is defined for this object") instead.
s = +"a"; t = s; t << "b"
u = nil
u ||= s
p Marshal.load(Marshal.dump(u))
p Marshal.load(Marshal.dump([u, 1, u]))
l = Marshal.load(Marshal.dump([u, u]))
p l[0] == l[1], l.size
b = +"x\0y"; c = b; c << "z"
v = nil
v ||= b
p Marshal.load(Marshal.dump(v)).bytesize
p Marshal.dump(v) == Marshal.dump("x\0yz")
