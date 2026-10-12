# Under --share-strings a bang handed on as an argument is its receiver's
# String, or nil, also where the call's arguments run ahead of its binding:
# beside a default that runs code, keyword arguments with several effects
# or out of order, and `new` with an initialize that has defaults.
def f(x = +"d") = (x << "!" if x; x)
def g(a, b = (puts "dflt"; 1)) = (a << "!" if a; a)
def two(a, b, c = +"c") = (a << "1" if a; b << "2" if b; [a, b, c])
def kw(a, k: 1, j: 2) = (a << "!" if a; [a, k, j])
def peek(a, b = (puts "peek"; 0)) = p(a)
s = +"ab"
f(s.upcase!)
f(s.upcase!)
f(s.downcase! || s)
f((s << "1").upcase!)
f(s << "2")
p s
t = +"x"
g(s.capitalize!)
g(s.capitalize!)
p s, two(s.swapcase!, t.upcase!), s, t
u = +"u"
kw(s.downcase!, k: (u << "1"), j: (u << "2"))
kw(s.upcase!, j: (u << "3"), k: (u << "4"))
p s, u
peek(s.downcase!)
class C
  def initialize(x = +"d", y = (puts "init"; 0)) = (@x = x)
  def bump = (@x << "!" if @x)
end
C.new(s.upcase!).bump
p s
arr = [+"ab", 1]
f(arr[0].upcase!)
f(arr[0].upcase!)
p arr
