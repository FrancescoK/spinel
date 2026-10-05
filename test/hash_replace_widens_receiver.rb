# Hash#replace from a Hash of another variant, or from a boxed value that
# holds one, widens the receiving Hash to the general one wherever it is
# held: a local, an ivar, a parameter (and its caller's Hash). It raised
# NoMethodError for a boxed argument on a local, and for any other variant
# on an ivar or a parameter. A boxed value that is no Hash raises CRuby's
# TypeError.
def mk(f) = f ? { "a" => 1 } : { 1 => "x" }
def pick(i) = i > 0 ? { "y" => 2 } : 3
k = { "x" => 1 }
p k.replace(pick(1)), k
h = { "q" => 2 }
h.replace(mk(false))
p h
g = { "q" => 2 }
g.replace(mk(true))
g["z"] = 3
p g
t = { "x" => 1 }
begin
  t.replace(pick(0))
rescue TypeError => e
  p e.message
end
p t
class K
  def initialize; @h = { "a" => 1 }; end
  def r(o)
    @h.replace(o)
    @h
  end
end
p K.new.r({ 1 => "x" }), K.new.r(mk(false)), K.new.r({ "b" => 2 })
def via(h, o) = h.replace(o)
x = { "a" => 1 }
p via(x, { 1 => "x" }), x
y = { "a" => 1 }
p via(y, mk(false)), y
e = { "a" => 1 }
p e.replace({}), e
