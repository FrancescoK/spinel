# A push/append statement on a receiver typed only at run time spreads a
# splat and reads the receiver once.

def src = [1, nil, "x"].first(1) + [2, 3]
def pick(a, other) = ARGV.empty? ? a : other

a = [0, 0, 0]
pick(a, "no").push(*src)
p a

b = [0]
pick(b, "no").append(4, *src, 5)
p b

c = ["s"]
tu = ["t", "u"]
pick(c, 1).push(*tu)
p c

d = [0.5]
fs = [1.5]
pick(d, :x).push(*fs, 2.5)
p d

e = [0]
pick(e, "no").push(*e.first(0))
p e

$n = 0
def counted(a) = ($n += 1; ARGV.empty? ? a : "no")
f = [0]
counted(f).append(1, 2)
p f
p $n

g = [0]
sv = [7, 8]
counted(g).push(*sv)
p g
p $n

h = [0]
pick(h, "no").push(9)
pick(h, "no") << 10
p h

class Box
  attr_reader :items
  def initialize = @items = []
  def push(*xs) = (@items.concat(xs); self)
end
bx = Box.new
bs = [1, 2]
pick(bx, [0]).push(*bs, 3)
p bx.items

q = Queue.new
qs = [11]
pick(q, [0]).push(*qs)
p q.pop

begin
  ss = [1]
  pick("str", [0]).push(*ss)
rescue NoMethodError => ex
  p ex.class
end
