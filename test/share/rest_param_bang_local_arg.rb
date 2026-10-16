# --share-strings: a bang on a String variable handed to a method's rest
# parameter (a local, an instance or global variable, in parentheses or not)
# answers the variable's String, or nil where nothing changed, and
# the method sees that String itself: appending to it changes the variable.
# The bang runs once, whether it is the argument, the arm of a conditional
# argument, or one of several arguments the rest collects.
def f(*xs) = (xs[0] << "!" if xs[0]; xs)
def ms(*t)
  t.each { |x| x << "!" if x }
  t
end
def mk(k, *t)
  t[0] << "?" if t[0]
  [k, t]
end
def sp(*xs) = p(xs, xs[0].equal?(xs[1]))
s = +"ab"
f(s.upcase!)
p s
f(s.upcase!)
p s
s = +"cd"
p ms(s.upcase!), s
p ms(s.upcase!), s
s = +"ef"
p ms(s.upcase! || +"z"), s
p ms(s.upcase! || +"z"), s
t = +"gh"
p ms(1 > 0 ? t.upcase! : +"z"), t
p ms(1 > 0 ? t.upcase! : +"z"), t
u = +"IJ"
p mk(1, u.downcase!), u
p mk(2, u.downcase!), u
w = +"kl"
p ms(+"x", w.upcase!, +"y"), w
v = +"mn"
sp(v.upcase!, v)
a = [v.downcase!]
sp(*a, v)
class K
  def initialize = (@s = +"iv")
  def go
    p ms(@s.upcase!), @s
    p ms((@s.downcase!)), @s
  end
end
K.new.go
x = +"ab"
p ms((x.upcase!)), x
p ms((x.upcase! || +"q")), x
$g = +"gl"
p ms($g.upcase!), $g
# ...with a keyword argument beside it, which runs ahead of the call
def tr(x) = x
def g(a, *xs, k: 0)
  xs.each { |x| x << "!" if x.is_a?(String) }
  [a, xs, k]
end
s2 = +"ab"
p g(0, 1, s2.upcase!, k: tr(3)), s2
p g(0, 1, s2.upcase!, k: tr(3)), s2
t2 = +"cd"
p g(0, t2.upcase!, k: tr(4)), t2
a2 = [+"ef", 1]
p g(0, a2[0].upcase!, k: tr(5)), a2
u2 = +"gh"
p g(0, u2.upcase! || +"z", k: tr(6)), u2
@iv2 = +"ij"
p g(0, @iv2.upcase!, k: tr(7)), @iv2
