# Array#slice and #at leave a block they are given unused: a literal one
# or one forwarded with &, on a typed Array or a boxed value, answers what
# the call without it answers -- nil for an index past the end

a = [1, 2]
p a.slice(1) { }
p a.slice(0..0) { }
p a.slice(5) { }
p [1, :x].slice(1) { }

def sl(a, &b) = a.slice(1, &b)
p sl([1, 2])
p sl(["a", "b"])
p sl({1 => 2})

def at5(a, &b) = a.at(5, &b)
p at5([1, 2])
x = [1, 2].at(5) { }
p x
