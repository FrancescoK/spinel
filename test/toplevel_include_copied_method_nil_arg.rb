# A bare call at the top level reaches the instance method of a module the
# top level includes; where that module took the method from another
# (`include IM` in M), the call binds M's copy. An argument that can be nil
# (an element of an Array filled after `[]`) marked only the first method of
# the name, IM's own, and the bare call was refused: "nil written into a
# non-nullable Integer slot: parameter h of f" (#9193).
module IM
  def f(h)
    M.f(h)
  end
end

module M
  def self.f(h)
    (h || 0.0).to_f
  end

  include IM
end

include M

xs = []
3.times { xs << 5 }
puts "qualified: #{M.f(xs[0])}"
puts "bare: #{f(xs[0])}"
ys = []
puts "bare nil: #{f(ys[0])}"
