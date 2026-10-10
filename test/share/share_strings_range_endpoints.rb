# A String Range keeps the String objects its endpoints were made from
# (#8321): a change in place to one shows through the Range, and #begin /
# #end answer that String itself.
# spinel: gc-stress
first = String.new("aa")
r = (first.."ad")
first << "b"
p r.begin, r, r.to_a, r.include?("ac")
b = r.begin
b << "!"
p first, r.first.equal?(first)

last = String.new("c")
x = ("a"...last)
last << "z"
p x.end, x.last, x
x.end << "q"
p last

class Holder
  def initialize(s) = @r = (s..s)
  def r = @r
end
s = String.new("m")
h = Holder.new(s)
s << "n"
p h.r.begin, h.r

def mk(n)
  t = String.new("k#{n}")
  rr = (t.."z")
  t << "+"
  rr
end
ranges = (1..3).map { |i| mk(i) }
GC.start
p ranges.map(&:begin)
p ranges

boxed = [first..first, 1]
first << "?"
p boxed[0]
