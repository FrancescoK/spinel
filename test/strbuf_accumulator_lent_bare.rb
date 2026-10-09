# An isolated accumulator keeps a callee's append without another call
# making the appending parameter take the handle.
# spinel: gc-minor
# spinel: share
def grow(v) = v << "x"
s = +""
3.times { |i| s << i.to_s }
grow(s)
p s
