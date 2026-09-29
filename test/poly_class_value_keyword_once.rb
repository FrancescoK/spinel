# A class method called on a value that may be one of several classes runs
# each keyword value (and a computed key) once, in source order, whichever
# class it turns out to be.
$log = []
def lit(x) = ($log << x; x)
class A
  def self.m(p1 = 51, p2 = 52, *r, **kw) = [:a, p1, p2, r, kw]
  def self.k(a:, b: 0) = [:a, a, b]
end
class B
  def self.m(p1 = 51, p2 = 52, *r, **kw) = [:b, p1, p2, r, kw]
  def self.k(a:, b: 0) = [:b, a, b]
end
s = [1]
h = { y: 9 }
[A, B].each do |o|
  p o.m(*s, lit(2), **h, z: lit(3), z: lit(4))
  p o.m(lit(5), z: lit(6), lit(:w) => lit(7))
  p o.k(b: lit(8), a: lit(9))
  p o.k(a: lit(10), a: lit(11))
end
p $log
