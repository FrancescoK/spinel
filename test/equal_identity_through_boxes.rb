# equal? is object identity. A String an out-of-line reader hands out
# (`def v = @v`) was a copy when the reader was the receiver, while the same
# call as the argument read the slot; and an Array, Hash or String compared
# with a boxed operand holding that very object answered false (the typed
# arms knew no boxed operand). Comparing two values that cannot be one
# object still runs both of them.
class Box
  def initialize(v) = @v = v
  def add(x) = (@v << x; self)
  def v = @v
end
w = +"w"
b = Box.new(w)
b.add("1")
p [b.v.equal?(w), w.equal?(b.v)]
x = b.v
p x.equal?(w)

a = [1, "x"]
ab = [a, 1][0]
p [a.equal?(ab), ab.equal?(a), a.equal?([[1, "x"], 1][0])]
ia = [1, 2]
p ia.equal?([ia, 3][0])
h = { k: 1 }
hb = [h, 1][0]
p [h.equal?(hb), hb.equal?(h), h.equal?([{ k: 1 }, 1][0])]
s = +"q"
sb = [s, 1][0]
p [s.equal?(sb), sb.equal?(s), s.equal?([+"q", 1][0])]
lit = "lit"
p lit.equal?(["lit", 1][0])

def r(v) = (puts "recv"; v)
def arg = (puts "arg"; 5)
p r(a).equal?(arg)
p r(h).equal?(arg)
p r(+"z").equal?(arg)
p r(+"z").eql?(arg)
p a.equal?(arg)
p h.equal?(arg)
p s.equal?(arg)
p s.eql?(arg)
