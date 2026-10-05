# Flag-only: without the flag (as on master) this program is refused.
# A proc, a lambda, a kept block and a Method are followed to the code they
# run: a String one appends to is the caller's, and a String it answers is
# whichever the body answers.
add = ->(s, t) { s << t; s }
a = +"a"
r = add.(a, "1")
r << "2"
p a
class Keeper
  def initialize(&b) = (@b = b)
  def run(x) = @b.call(x)
end
k = Keeper.new { |x| x << "!" }
b = +"b"
k.run(b)
p b
def shout(s) = s.upcase!
c = +"c"
m = method(:shout)
[m].each { |f| f.call(c) }
p c
words = [+"x", +"y"]
bang = proc { |w| w << "?" }
words.each(&bang)
p words
fresh = ->(s) { s + "+" }
d = +"d"
e = fresh.call(d)
e << "~"
p d, e
cur = ->(s, t) { s << t }.curry
f = +"f"
cur[f]["*"]
p f
h = { k: proc { |s| s.replace("new") } }
g = +"g"
h[:k].call(g)
p g
