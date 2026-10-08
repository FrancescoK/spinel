# A splat converts its operand through #to_a: a Hash spreads its [key, value]
# pairs, a Struct its members, an object its own #to_a.
# spinel: gc-stress
h = {a: 1}
p [*h, 2]
p [*h]
p [0, *h]
x = *h
p x
a, b = *h
p a
p b

def rest(*r) = r
p rest(*h)
p rest(1, *{b: 2})

s = {"k" => 2}
p [*s, 3]
i = {1 => 2, 3 => 4}
p [*i, 5]
p [*{}, 6]

class Box
  def initialize; @h = {x: 1, y: 2}; end
  def all = [*@h]
end
p Box.new.all

$g = {"q" => 3}
p [*$g, 0]

def with_end(h) = [*h, :end]
p with_end({z: 9})

def yield_splat(h)
  yield(*h)
end
yield_splat({k: 1}) { |pair| p pair }

class Pairs
  def to_a = [7, 8]
end
p [*Pairs.new]

Pt = Struct.new(:a, :b)
p [*Pt.new(1, 2)]

v = ARGV.size > 5 ? 5 : {a: 1}
p [*v, 4]
p rest(*v)
y = *v
p y
p([1].map { next *v })

p [*1..3, 4]
p [*nil, 1]
p [*"s", 1]
