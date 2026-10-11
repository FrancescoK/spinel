# A boxed receiver's case conversion (`v.upcase` with v boxed) answers a
# new String in a plain box. Stored into a container whose elements are
# changed in place (`k[0] << "!"`), that box was a value: the append made
# a new String and the element kept its old text. Under --share-strings
# the store lifts the box into a handle, so the element is the String the
# mutation reaches. A Symbol receiver's answer is a Symbol, kept as it is.

# procs in a Hash, whose parameters are boxed: one stores its argument,
# the other a new String
k = []
h = { a: proc { |v| k << v }, b: proc { |v| k << v.upcase } }
s = +"s"
h[:a].call(s)
h[:b].call(s)
h[:a].call(1)
k[0] << "!"; k[1] << "?"
p [s, k, s.equal?(k[0])]

# a proc called with a String and with something else
q = []
pb = proc { |v| q << v.downcase }
pb.call(+"AB")
pb.call(:SYM)
q[0] << "?"
q[0].upcase!
p q

# a boxed local's conversion, pushed, in a literal and as a Hash value
v = [+"xy", 2][0]
a = [1]
a << v.swapcase
a.push(v.downcase)
a[1] << "!"
a[2].concat("?")
lit = [v.upcase, 0]
lit[0].downcase!
hv = { n: v.upcase }
hv[:n].prepend(">")
p a, lit, hv, v

# the element read back names the same String
e = []
e << v.upcase
first = e[0]
e[0] << "!"
p e, first, first.equal?(e[0])

# what another object hands back (a Thread's value, a Fiber's, a Queue's)
# is no new String: the element is that String itself
s2 = +"t"
th = [Thread.new { s2 }, 1][0]
fb = [Fiber.new { s2 }, 1][0]
qu = Queue.new
qu << s2
qb = [qu, 1][0]
g = [v.upcase]
g << th.value << fb.resume << qb.deq
g[0] << "!"
p g, g[1].equal?(s2), g[2].equal?(s2), g[3].equal?(s2)
