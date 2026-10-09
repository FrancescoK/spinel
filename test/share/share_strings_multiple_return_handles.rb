# spinel: share
# spinel: gc-minor
# `return a, b` gathers its values into a new Array: where the rule shares
# that Array's elements, a new String in it is a handle too, so an append
# through the element lands in the Array, and a shared one stays the
# String its other names hold.
module M
  def pair(f)
    return @x, @x * 2
  ensure
    @n = @x.size
  end
end
class A; include M; def initialize(x) = @x = x; end
class B; def pair(f) = "e".dup; end
src = "s".dup
os = [A.new(src), B.new]
r = os[0].pair(true)
r[1] << "!"
p r, src
r[0] << "#"
p r, src, r[0].equal?(src), os[1].pair(1)

class C
  def initialize(x) = @x = x
  def two
    return @x, @x + "t"
  end
end
src = "s".dup
c = C.new(src)
t = c.two
t[1] << "?"
t[0] << "%"
p t, src
