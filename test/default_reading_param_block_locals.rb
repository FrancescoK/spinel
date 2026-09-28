# A parameter default filled in at the call site declares its own block
# parameters and locals there, including when it reads an earlier parameter.

class K
  def initialize(a:, b: [a].map { |n| n * 2 }.first) = (@v = [a, b])
  attr_reader :v
end
p K.new(a: 1).v
k = [K].first
p k.new(a: 2).v

def kw_then(a:, b: a.then { |q| q + 1 }) = [a, b]
p kw_then(a: 3)

def kw_local(a:, b: (x = a; x + 1)) = [a, b]
p kw_local(a: 3)

def pos_map(a, b = [a].map { |n| n * 2 }.first) = [a, b]
p pos_map(3)

def pos_local(a, b = (x = [a]; x + ["y"])) = [a, b]
3.times { |i| p pos_local("s#{i}") }

def no_read(a, b = [1].map { |n| n * 2 }.first) = [a, b]
p no_read(0)

def lam(a:, b: ->(z) { z + a }.call(1)) = [a, b]
p lam(a: 3)

def ewo(a, b = [a, 2].each_with_object([]) { |v, acc| acc << v * 10 }) = b
p ewo(3)
p [1, 2].map { |e| ewo(e) }

n = "caller n"
x = "caller x"
def up(a:, b: [a, a].map { |n| n.upcase }.join) = b
p up(a: "q")
p kw_local(a: 7)
p n
p x
p method(:up).call(a: "r")
