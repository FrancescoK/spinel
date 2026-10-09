# A String variable an explicit super hands to the parent's parameter, made
# the shared handle by what the parent hands it on to, is the same String.
# spinel: gc-minor
# spinel: share
def grow(v) = v << "x"
grow([])
class P
  def m(p1) = (grow(p1); p1.size)
end
class C < P
  def m
    v = +"s1"
    super(v)
    v
  end
end
p C.new.m

module M
  def n(p1, p2 = @d) = (grow(p1); [p1.size, p2])
end
class D
  include M
  def n
    @d = 0
    w = +"t1"
    super(w)
    w
  end
end
p D.new.n
