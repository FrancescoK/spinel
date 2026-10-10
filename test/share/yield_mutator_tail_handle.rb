# A block, a begin, a then block, a loop's break or a next that ends in a
# String method that always answers its receiver (<<, concat, replace,
# insert, prepend) answers that String itself: kept, it is the same
# object, and a change through either name shows through the other (#8400).
def keep
  yield
end
def keep2(x)
  yield x
end

buf = +"k"
v = keep { buf.concat("a") }
v << "z"
p buf, v, v.equal?(buf)

a = +"m"
w = keep { a.replace("r") }
w << "1"
p a, w.equal?(a)

b = +"n"
x = keep { b.insert(0, "i") }
x << "2"
p b

d = +"o"
y = keep { d.prepend("p") }
y << "3"
p d

e = +"q"
z = keep { e.concat("1", "2") }
z << "4"
p e

f = +"s"
u = keep { f << "a" << "b" }
u << "5"
p f, u.equal?(f)

g = +"t"
t = keep { g.concat("x"); g.replace("T") }
t << "6"
p g

h = +"u"
r = keep2(1) { |i| i > 0 ? h.concat("+") : h }
r << "7"
p h

i = +"v"
q = keep { i.prepend("<", ">") }
q << "8"
p i

$g = +"g"
gx = keep { $g.insert(1, "-") }
gx << "a"
p $g

bb = +"b"
bv = begin
  bb.concat("e")
end
bv << "b"
p bb

c = +"c"
cw = begin
  raise "x" if c.empty?
  c.replace("C")
rescue
  c
end
cw << "c"
p c

s = +"s"
st = 1.then { s.prepend(">") }
st << "e"
p s

l = +"l"
lr = loop { break l.concat("!") }
lr << "f"
p l

n = +"n"
nq = keep { next n.insert(0, "N") if n.size > 0; n }
nq << "g"
p n
