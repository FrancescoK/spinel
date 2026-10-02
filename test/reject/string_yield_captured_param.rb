# A String yielded to a block whose parameter a lambda captures and appends
# to, and read after the call: the spliced yield binds the parameter to a
# copy, so the read would miss the append. Refused rather than compiled with
# the append lost.
def y1(v) = yield(v)
u = +"a"
y1(u) { |q| l = lambda { q << "#" }; l.() }
p u
