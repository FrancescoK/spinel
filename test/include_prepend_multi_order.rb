# `include A, B` includes B first, so A comes first among the ancestors and
# its method wins, with super reaching B's; `prepend A, B` the same way. The
# arguments were taken left to right, so B's method won, super in A's was
# never reached, and ancestors listed the two the other way round.

module M1
  def foo = [:m1]
  def bar = :m1_bar
end
module M2
  def foo = [:m2, *super]
end
module M3
  def foo = [:m3, *super]
end

class L
  include M3, M2, M1
end
p L.new.foo, L.new.bar, L.ancestors.take(4), L.included_modules.take(3)

# one per statement keeps its order
class L2
  include M1
  include M2
end
p L2.new.foo, L2.ancestors.take(3)

module P1
  def foo = [:p1, *super]
end
module P2
  def foo = [:p2, *super]
end
class P
  def foo = [:p]
  prepend P2, P1
end
p P.new.foo, P.ancestors.take(3)
