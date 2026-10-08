# A String bound out of a splat's gathered Array into a parameter whose
# slot is an sp_String * handle (the first call passes an aliased, changed
# local: master's shared-mutable String, #3227, without --share-strings): a
# plain String element becomes a handle of its own, which nothing roots
# until the callee does, while the rest parameter's Array is built after it
# in the same argument list. Under SPINEL_GC_STRESS=2 that handle was
# collected and the call read a freed object (gc-stress-test); with
# --share-strings it was already made ahead of the call, in a rooted temp.
# spinel: gc-stress
LONG = "!" * 100

def g1(a = nil, *r, z) = (a << LONG if a.is_a?(String); [a.size, r, z])

t = +"t"; u = t; t << ""
p g1(t, *[], 1), u.size
e = []
p g1(+"plain", *e, 2)
w = +"w"
p g1(w, *[3], 4), w.size
