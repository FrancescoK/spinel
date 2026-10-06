# casecmp / casecmp? on a boxed receiver, given a block. CRuby ignores the
# block, and the emitter's sp_poly_casecmp arm takes the call with one as
# without, answering a boxed true, false, Integer or nil. The inference typed
# only the blockless call boxed: with a block, casecmp? was typed a bool, so
# the boxed answer went into an sp_bool slot, or into sp_box_bool under a
# block that breaks, and the generated C did not build.

def t(k)
  log = []
  r = ["Hello", :brp][k]
  s = [:Hello, 1][k]
  p r.casecmp?("hello") { |*b| 1 }
  p(r.casecmp?((log << :a; "HELLO")) { |*b| log << b; break :cut })
  p(s.casecmp?(:hello) { |*b| break :cut })
  p(s.casecmp?("hello") { |*b| 1 })
  p(r.casecmp?(nil) { |*b| break :cut })
  p(r.casecmp("hellp") { |*b| break :cut })
  p(s.casecmp(:HELLO) { |*b| 1 })
  n = k == 0 ? nil : "x"
  p(n.casecmp?("x") { |*b| break :cut }) rescue p $!.class
  p log
end

t(ARGV.size)
