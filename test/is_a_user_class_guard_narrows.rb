# is_a?(K) on a boxed value narrows it to K for a user class K with no
# subclass and no mixin: the guarded calls bind to K's methods (#10552),
# while a subclass, a module, a singleton method, a prepend and an
# Enumerable class still answer as CRuby does

class Int; attr_reader :value; def initialize(v) = @value = v; def tag = "Int"; end
class Str; def tag = "Str"; end
class Lone; def tag = "Lone"; end
class P; def tag = "P"; end
class Sub < P; def tag = "Sub"; end
module M; def tag = "M+" + super; end
class Q; prepend M; def tag = "Q"; end
module Mod; end
class W; include Mod; def tag = "W"; end
class Bag
  include Enumerable
  def initialize(*a) = @a = a
  def each(&b) = @a.each(&b)
end

def postfix(x)
  return x.value if x.is_a?(Int)
  0
end
def block(x)
  if x.is_a?(Int); return x.value; end
  0
end
def tern(x) = x.is_a?(Int) ? x.tag : "-"
def lone(x) = x.is_a?(Lone) ? x.tag : "-"
def sub(x) = x.is_a?(P) ? x.tag : "no"
def mod(x) = x.is_a?(Mod) ? x.tag : "nm"
def pre(x) = x.is_a?(Q) ? x.tag : "nq"
def rewrite(x)
  if x.is_a?(Int)
    x = Str.new
    return x.tag
  end
  "r"
end

i = Int.new(1)
s = Lone.new; def s.tag = "single"
p postfix(i), postfix(Str.new), block(Int.new(3)), block(Str.new)
p tern(i), tern(Str.new), lone(Lone.new), lone(s), lone(i)
p sub(P.new), sub(Sub.new), sub(Str.new)
p mod(W.new), mod(Str.new), pre(Q.new), pre(Str.new)
p rewrite(i), rewrite(Str.new)
p [i, Str.new, 3, "x"].map { |y| y.is_a?(Int) ? y.value + 1 : 0 }
[Bag.new(3, 1, 2), "x"].each { |v| p [v.min, v.max] if v.is_a?(Bag) }
