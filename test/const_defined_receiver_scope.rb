# `R.const_defined?(:N)` looks at R, its ancestors, the modules they include
# and the top level, as CRuby does: a constant only another class holds is
# not defined for R (#9876), with a literal receiver or one known at run time.
class A
  X = 1
  class Inner; end
end
class B
end
class C < A
end
module M
  Y = 2
end
class D
  include M
  def hi = 1
end
TOP = 3
def ask(k, n)
  k.const_defined?(n)
end
p B.const_defined?(:X), C.const_defined?(:X), A.const_defined?(:X)
p ask(B, :X), ask(A, :X), ask(C, :X)
p B.const_defined?(:Inner), A.const_defined?(:Inner)
p D.const_defined?(:Y), B.const_defined?(:Y), M.const_defined?(:Y)
p B.const_defined?(:TOP), M.const_defined?(:TOP), ask(B, :TOP)
p B.const_defined?(:A), A.const_defined?(:X, false), C.const_defined?(:X, false)
p ask(D, :Y), ask(B, :Y)

module K
  Z = 9
end
class E
  include K
end
class F < E
end
def ask_z(k) = k.const_defined?(:Z)
p E.const_defined?(:Z), F.const_defined?(:Z), ask_z(E), ask_z(F)
