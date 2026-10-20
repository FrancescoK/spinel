# spinel: gc-stress
# A box takes the handle a String's producer hands on where the String plan
# boxes the handle. An argument that ran ahead of its call holding that
# handle (a parenthesized append bound to a keyword or a poly parameter)
# was boxed as the bytes it read there, so a change through the parameter
# missed the String. A reopened String method's call run through its
# proc-form clone hands back a box, which a lambda's answer unboxed and
# boxed again as bytes. And a block's value that is a route answering its
# operand (`v.capitalize` of an empty v) was boxed as the route's bytes.
class String
  def pm(a) = yield(a)
  def ps(a) = yield(a)
end
$g = +"glob"
def kw(a, k: 1, j: 2) = (k << "!" if k.is_a?(String); [a, k, j])
def pos(a, b, c = 0) = (b << "?" if b.is_a?(String); [a, b, c])
pos(1, 2)   # b is a poly parameter: it also receives an Integer
class Holder
  def initialize = @iv = +"iv"
  def iv = @iv
  def lam = -> { "ab".pm(1) { |v| @iv } }
end
s = +"ab"; u = +"u"
r = kw(s.downcase!, k: (u << "1"), j: (u << "2"))
p u, r, r[1].equal?(u)
w = +"w"
q = pos(s.upcase!, (w << "1"), (w << "2").size)
p w, q, q[1].equal?(w)
o = +"outer"
f = -> { "ab".pm(1) { |v| o } }
x = f.call
x << "-1"
p o, x.equal?(o)
b = Holder.new
y = b.lam.call
y << "-2"
p b.iv
gl = -> { "z".pm(1) { |v| $g } }
gl.call << "-3"
p $g
h = -> { "x".pm(1) { |v| +"pp" } }
c = [h.call, 1]
c[0] << "-4"
p c
e = +""
z = "ab".ps(e) { |v| v.capitalize }
z << "c"
p e, z.equal?(e)
e2 = +""
t = "ab".ps(e2) { |v| v.capitalize }
arr = [t, 2]
arr[0] << "d"
p e2, "ab".ps(+"xy") { |v| v.capitalize }

# a positional argument that runs first (a later one changes the String it
# read) and is bound to a poly parameter takes the handle: a bang, an
# append, a conditional with side effects, a sequence ahead of a conditional
w2 = +"w"; s2 = +"ab"
q2 = pos(s2.upcase!, (w2 << "1"), (w2 << "2"))
p w2, q2, q2[1].equal?(w2)
w3 = +"w"
q3 = pos((w3 << "1"), (w3 << "2"), 0)
p w3, q3, q3[0].equal?(w3), q3[1].equal?(w3)
q3 = pos((w3 << "1"), w3.downcase!)
p w3, q3[0].equal?(w3)
def pc(a, b) = (a << "?" if a.is_a?(String); [a, b])
pc(1, 2)
def runc(c)
  u = +"u"; w = +"w"; n = 0
  r = pc((c ? (n += 1; u) : w), (u << "x"))
  p u, w, n, c ? r[0].equal?(u) : r[0].equal?(w)
  r = pc((c ? (u << "1") : w), (u << "y"))
  p u, w, c ? r[0].equal?(u) : r[0].equal?(w)
  r = pc((n += 1; c ? u : w), (u << "z"))
  p u, w, c ? r[0].equal?(u) : r[0].equal?(w)
end
runc(true)
runc(false)
