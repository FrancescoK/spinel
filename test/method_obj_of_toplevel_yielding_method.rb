# A Method object of a top-level method that yields calls it with the block
# it is given
def x
  yield 1
end

def twice(a)
  [yield(a), yield(a + 1)]
end

def maybe
  block_given? ? yield(:given) : :none
end

def fwd(v, &) = twice(v, &)

m = method(:x)
m.call { |v| p v }

t = method(:twice)
p t.call(10) { |v| v * 2 }
p t.call(3) { |v| "s#{v}" }

g = method(:maybe)
p g.call
p g.call { |s| s }

f = method(:fwd)
p f.call(5) { |v| v - 1 }

p x { |v| v + 100 }
p twice(1) { |v| v }
