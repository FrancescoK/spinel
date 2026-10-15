# spinel: gc-minor
# spinel: gc-stress
# A method whose answer is its block's value -- `blk.call(x)`, `blk&.call(x)`,
# or a call that hands the block on (`&blk`, `...`) to a method that yields
# -- is spliced at a call with a literal block like a method that yields, so
# a String the block answers is the call's String itself. Kept as an Array
# element, a Hash value, an instance variable, a pushed or stored element, it
# is the String the block named, shared with that name, and changed in place
# through either: a String the block makes new, or hands on from a frozen
# literal, is a String of its own. A call the C dispatches on the receiver's
# class is another matter (test/share/refuse/dispatched_*).
def bc(a, i, &b) = b.call(a[i])
def sc(a, i, &b) = b&.call(a[i])
def yf(a, i); yield a[i]; end
def fw(a, i, &b) = yf(a, i, &b)
def fw2(a, i, &b) = fw(a, i, &b)
def fa(...) = yf(...)
def one(&b) = b.call(0)
def two(k, &b) = one(&b)

s = +"src"
t = +"tee"
a = [1, bc([t, +"b"], 0) { |x| s }]
a[1] << "!"
p a, s, a[1].equal?(s)
s << "s"
p a

a = [sc([t, +"b"], 0) { |x| s }, sc([t, +"b"], 0) { |x| x }]
a[0] << "?"
a[1] << "?"
p a, s, t, a[0].equal?(s), a[1].equal?(t)

a = [fw([t, +"b"], 1) { |x| s }, fw2([t, +"b"], 0) { |x| x }, fa([t, +"b"], 0) { |x| s }]
a[0] << "1"
a[1] << "2"
a[2] << "3"
p a, s, t, a[0].equal?(s), a[1].equal?(t), a[2].equal?(s)

h = { k: bc([t, +"b"], 0) { |x| s }, j: two(0) { |k| s } }
h[:k] << "h"
p h, s, h[:j].equal?(s)

@iv = [0, two(0) { |k| s }]
@iv[1] << "i"
p @iv, s

b = []
b << bc([t, +"b"], 0) { |x| x.to_s }
b << sc([t, +"b"], 0) { |x| s }
b[0] << "#"
b[1] << "$"
p b, s, t, b[0].equal?(t), b[1].equal?(s)

c = [1, 2]
c[1] = bc([t, +"b"], 0) { |x| s }
c[1] << "c"
p c, s

n = [bc([t, +"b"], 0) { |x| "lit" }, bc([t, +"b"], 0) { |x| x.dup }, bc([t, +"b"], 0) { |x| +"new" }]
n[0].frozen? ? nil : n[0] << "!"
n[1] << "!"
n[2] << "!"
p n, t, n[1].equal?(t), n[0].frozen?
s << "z"
t << "z"
p a, h, b, c, n

class K
  def bc(&b) = b.call
  def go(s) = [bc { s }]
end
class Other < K
  def other = 1
end
q = +"qq"
k = Other.new.go(q)
k[0] << "!"
p k, q, k[0].equal?(q)
