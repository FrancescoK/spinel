# Under --share-strings an argument that hands on a shared String (a
# conditional, a call that answers its argument) into a parameter that is
# the handle is that String also where the call's arguments run ahead of
# its binding beside a default that runs code, as it is where the
# argument runs at its slot. It ran into a copy, which the binding
# wrapped in a new handle. Covered: a condition that runs a method, `&&`
# after a bang, a method that answers its argument, `new` with an
# initialize that has a default, and a call in a block.
$n = 0
def bump = ($n += 1; true)
def id(v) = ($n += 1; v)
def f(x = +"d") = x << "!"
s = +"ab"
f(bump ? s : s)
p s
f(s.sub!("a", "Z") && s)
p s
f(id(s))
p s
class C
  def initialize(x = +"d") = (@x = x; x << "?")
  def x = @x
end
c = C.new(s.upcase! ? s : s)
p s, c.x.equal?(s)
[1].each { f(s.downcase! ? s : s) }
p s, $n
