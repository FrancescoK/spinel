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

# Binary Strings omit the encoding ivar, through both a handle and a plain
# String. Include a NUL and repeated links, and retain UTF-8 metadata.
s = +"\xFF".b; t = s; t << "\0".b
u = nil
u ||= s
p Marshal.dump(u).bytes
p Marshal.dump([u, u]).bytes
p Marshal.dump("\xFF\0".b).bytes
p Marshal.dump("".b).bytes
p Marshal.dump("ascii".b).bytes
p Marshal.dump("text").bytes
s = +"é"; t = s; t << "!"
u = nil
u ||= s
p Marshal.dump(u).bytes
