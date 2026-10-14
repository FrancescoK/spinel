# A `||`, `&&` or `if` with a bang on a boxed receiver on an arm, handed to
# a parameter, a local, an ivar or a boxed slot: the arm that answers the
# receiver hands on its String, the other arm its own, so the change made
# through the result shows in the Array.
def m(t)
  t << "!"
  t
end
a = [+"ab", 1]
r = m(a[0].upcase! || +"z")
p a, r, r.equal?(a[0])
r = m(a[0].upcase! || +"z")
p a, r
x = a[0].downcase! || +"n"
x << "?"
p a, x, x.equal?(a[0])
@x = a[0].downcase! || a[0]
@x << "#"
p a, @x
c = ARGV.size == 0
r = m(c ? a[0].swapcase! : +"q")
p a, r
r = m(!c ? a[0].swapcase! : +"q")
p a, r
w = nil
w ||= a[0].upcase! || +"z"
w << "%"
p a, w.equal?(a[0])
# the same into a rest parameter, beside other arguments and a splat
def ms(*t) = (t[0] << "!"; t[0])
b = [+"cd", 1]
w = ms(b[0].upcase! || +"z")
p b, w
w = ms(b[0].upcase! || +"z", 2)
p b, w
w = ms(b[0].upcase! || +"z", *[3])
p b, w
w = ms(c ? b[0].downcase! : +"q")
p b, w
