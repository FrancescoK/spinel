# spinel: gc-stress
# A user writer nested in a `(a, b)` of a multiple assignment from a boxed Array
# takes a boxed parameter: it is handed the boxed element, and a parameter typed
# from its other callers alone took it through an unchecked cast (a Float read
# as an Integer, a String as an sp_int). Under GC stress for the String.
class W4
  def a=(v); @a = v; end
  def b=(v); @b = v; end
  def a = @a
  def b = @b
end
def rhs(i) = [[i, "s#{i}"], 3]
w = W4.new
w.a = 1; w.b = 2
s = 0
300.times do |i|
  t = W4.new
  (t.a, t.b), x = rhs(i)
  pad = "p" * 40
  s += pad.size + t.b.size
end
p s, w.a, w.b

class W5
  def b=(v); @b = v + 1; end
  def b = @b
end
w = W5.new
w.b = 2
def rhs5 = [[1, 5], 3]
(x, w.b), y = rhs5
p w.b
def rhs52 = [[1, 5.5], 3]
(x, w.b), y = rhs52
p w.b
