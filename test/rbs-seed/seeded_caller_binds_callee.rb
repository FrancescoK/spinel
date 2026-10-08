# A parameter is narrowed only when every call site agrees, and a method
# declared in --rbs is a call site like any other. The last binding round runs
# after the fixpoint, and the seed had been lost by then, so the seeded caller
# contributed UNKNOWN: `callee`'s parameter narrowed to Time from its one other
# call site, and the call inside `wrapper` -- whose own parameter is `untyped`,
# the weakest thing an .rbs can say -- no longer fitted. The .rbs never
# mentions `callee` (#4165).
# spinel: rbs-seed-run
class M
  def self.callee(t)
    t.to_s
  end

  def self.wrapper(t)
    M.callee(t)
  end
end

def poly(n)
  n > 0 ? 7 : "x"
end

puts M.callee(7)
puts M.wrapper(poly(1))
puts M.wrapper(poly(0))
