# A yielding method of a Fiber or Thread reopening, or of a module it mixes
# in, called with a block or without one, and forwarded to through `...`
class Fiber
  def wrap(x)
    block_given? ? yield + x : x
  end
end

module Around
  def around(tag)
    "#{tag}:#{yield(tag)}"
  end
end
Thread.include(Around)

def Fiber.wrap(...)
  Fiber.current.wrap(...)
end

f = Fiber.new { 1 }
p f.wrap(2)
p f.wrap(2) { 3 }
p Fiber.wrap(4) { 5 }
p Fiber.wrap(6)
t = Thread.new { 7 }
p t.around("t") { |s| s * 2 }
p t.value
p f.wrap(2) { |v = 1| v }
class Fiber
  def pairs
    yield [1, 2], {a: 3}
  end
end
f.pairs { |a, h| p [a.sum, h[:a]] }
