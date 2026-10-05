# A self-returning iterator with a breaking block whose receiver has no
# value of its own: String Range#step and #% given one argument too many
# raise ArgumentError, and the block form is lowered to an each over that
# call. The break wrapper spills an impure receiver into a temp of the
# receiver's type, which was void here, so the generated C did not build.
# The temp is a nil now, and the call raises as CRuby does.

def t(k)
  log = []
  r = ("a".."c")
  p(begin; r.step("s", 5) { |*b| break :c }; rescue ArgumentError => e; e.message; end)
  p(begin; (log << :r; r).step((log << :a; "s"), 5) { |*b| log << b; break :c }; rescue ArgumentError => e; e.class; end)
  p(r.step(1) { |x| break x })
  p log
end

t(ARGV.size)
