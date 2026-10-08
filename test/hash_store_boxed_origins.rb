# Stores through a box widen the Hash it holds, including a method result,
# an ivar and the arguments of a proc. Other references see the same store.
# spinel: gc-minor
def pick(i) = [{a: 1}, [1, 2]][i]
pick(ARGV.size)[0] = 5
p pick(0)

h1 = {a: 1}
b1 = [h1, 1][ARGV.size]
b1[0] = 5
p h1

@h = {a: 1}
b2 = [@h, 1][ARGV.size]
b2[0] = 5
p @h

h3 = {a: 1}
b3 = [h3, 1][ARGV.size]
b3["k"] = 5
p h3

h4 = {a: 1}
[h4, 1][ARGV.size][0] = 5
p h4

[{a: 1}, 1][ARGV.size][0] = 5
p :stored

h5 = {a: 1}
f5 = ->(x) { x[:k] = "v" }
f5.(h5)
p h5

h6 = {a: 1}
f6 = ->(x) { x[0] = 5 }
f6.(h6)
p h6

h7 = {0 => 1}
f7 = ->(x) { x[0] = "v" }
f7.(h7)
p h7

h8 = {0 => 1}
f8 = ->(x) { x[:k] = "v" }
f8.([h8, 1][ARGV.size])
p h8

h9 = {0 => 1}
f9 = ->(x) { x[:k] = "v" }
f9.(h9)
p h9

# Both return paths and both call sites contribute their original Hash.
def choose(i, h)
  return h if i == 0
  [h, 1][i - 1]
end
h10 = {a: 1}
h11 = {0 => 2}
choose(ARGV.size, h10).store("k", 3)
choose(ARGV.size + 1, h11).store(:k, "v")
p h10, h11

f10 = proc { |x| x.store(0, "v") }
h12 = {a: 1}
h13 = {0 => 2}
f10.call([h12, 1][ARGV.size])
f10.yield([h13, 1][ARGV.size])
p h12, h13

# Disjoint ivars with the same name keep their own origins.
class FirstBox
  def initialize = @h = {a: 1}
  def put
    b = [@h, 1][ARGV.size]
    b.store(0, 5)
  end
  def value = @h
end
class SecondBox
  def initialize = @h = {b: 2}
  def value = @h
end
one = FirstBox.new
two = SecondBox.new
one.put
p one.value, two.value
