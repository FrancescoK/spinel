# A String that is the shared handle, passed ahead of a splat to a parameter
# the method appends to while a later argument rebinds the variable
# (`gath(s, *xs, (s = +"v"; 9))`): the call gathers every argument, and the
# parameter, lent a slot, took a copy out of the gathered Array, so the
# String's other name never saw the append. CRuby appends to the String s
# held when it was read. Each method has one call, so no other call site
# makes its parameter the handle; each probe appends LONG, which always
# reallocates.
# spinel: gc-minor
LONG = "!" * 100

def seen(s) = [s[0], s.size]
xs = [+"y", +"w"]

def g1(a, b, *r, z) = (a << LONG; [seen(a), z])
s1 = +"A"; o1 = s1; o1 << ""; p g1(s1, *xs, (s1 = +"a"; 9)), seen(s1), seen(o1)
def g2(a, b = 1, *r) = (a.concat(LONG); r.size)
s2 = +"B"; o2 = s2; o2 << ""; p g2(s2, *xs, (s2 = +"b"; 9)), seen(s2), seen(o2)
def g3(a, b, *r) = (b << LONG; r.size)
s3 = +"C"; o3 = s3; o3 << ""; p g3(1, s3, *xs, (s3 = +"c"; 9)), seen(s3), seen(o3)
def g4(a, *r, k: 0) = (a.insert(0, LONG); k)
s4 = +"D"; o4 = s4; o4 << ""; p g4(s4, *xs, k: (s4 = +"d"; 9)), seen(s4), seen(o4)
