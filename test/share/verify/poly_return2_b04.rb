# attr_reader mixed with methods in poly
module M
  def get(f) = f ? @x : @x + "m"
end
class A; include M; attr_reader :x; def initialize(x) = @x = x; end
class B; attr_reader :x; def initialize(x) = @x = x; def get(f) = @x; end
s1 = "s".dup
s2 = "t".dup
os = [A.new(s1), B.new(s2)]
a = os[0].x
b = os[1].x
c = os[0].get(false)
d = os[1].get(true)
e = os[0].get(true)
c << "c"
p a, b, c, d, e, s1, s2
d << "d"
e << "e"
p a, b, c, d, e, s1, s2
