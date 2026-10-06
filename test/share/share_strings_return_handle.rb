# Flag-only: without the flag (as on master) each returned String is a copy and misses the change.
# A method that answers the String it was handed (or one it holds) on every
# path returns that String: a caller's name for the answer is the same
# object, whether the method answers a parameter, an append chain on it, an
# ivar, a conditional of such, or another such method's answer; a dropped
# answer costs nothing and changes nothing.
def add(buf, x) = (buf << x)
def add2(buf, x, y)
  buf << x
  buf << y
end
def pick(a, b, first) = (first ? a : b)
def via(buf) = add(buf, "v")
def maybe(buf, keep)
  return nil unless keep
  buf << "?"
end
class Doc
  def initialize = @out = +"<"
  def tag(t) = (@out << t << ">")
  def out = @out
end
s = +"s"
t = add(s, "1")
t << "2"
p s, t.equal?(s)
add2(s, "3", "4")
p s
u = pick(s, +"other", true)
u << "5"
p s
w = via(s)
w << "6"
p s, w.equal?(s)
m = maybe(s, true)
m << "7"
p s, maybe(s, false)
d = Doc.new
r = d.tag("a")
r << "b"
d.tag("c")
p d.out, r.equal?(d.out)
kept = []
3.times { |i| kept << add(+"k", i.to_s) }
kept.each { |k| k << "!" }
p kept
