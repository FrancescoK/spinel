# A String gathered into a rest and yielded with a splat to a block whose
# parameter a lambda captures and appends to: the yield hands the block a
# copy, as for any splat into a yield, so the append would not reach the
# caller's String. It is refused at the call, as the direct append is
# (test/string_yield_captured_param_copy_unseen.rb covers unseen copies).
def y2(*a) = yield(*a)
u = +"c"
y2(u) { |q| l = -> { q << "#" }; l.() }
p u
