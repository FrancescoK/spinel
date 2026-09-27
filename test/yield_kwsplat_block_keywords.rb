# A `**h` yielded to a block reaches the block's keyword params and
# **kwrest, and a trailing kwargs hash is never bound to a positional of a
# block that takes keywords.

def y1(h)
  yield 1, **h
end
y1({ a: 1 }) { |a, **o| p [a, o] }

def y2 = yield(1, **{ b: 2 })
y2 { |a, **o| p [a, o] }

def y3(h) = yield(**h)
y3({ c: 3 }) { |c:| p c }
y3({ k: 1 }) { |a, k:| p [a, k] }

def c1(h, &b) = b.call(1, **h)
c1({ a: 1 }) { |a, **o| p [a, o] }
def c2(h, &b) = b.(**h)
c2({ c: 3 }) { |c:| p c }

def lit = yield(k: 5)
lit { |a, k:| p [a, k] }
lit { |a, **o| p [a, o] }
lit { |a, b = 2, **o| p [a, b, o] }

def mix(h) = yield(1, x: 9, **h)
mix({ k: 6 }) { |a, x:, k:| p [a, x, k] }
def splat_wins(h) = yield(k: 1, **h)
splat_wins({ k: 3 }) { |k:| p k }
def literal_wins(h) = yield(**h, k: 1)
literal_wins({ k: 3 }) { |k:| p k }

def opt(h) = yield(1, **h)
opt({ k: 2 }) { |a, k: 10| p a + k }
opt({}) { |a, k: 10| p a + k }
opt({ k: "s" }) { |a, k: "d"| p k + "!" }
opt({ k: 1.5, j: [1] }) { |a, k: 0.0, **r| p [k * 2, r] }
opt({ a: 1, "s" => 2 }) { |x, a:, **r| p [x, a, r] }

p(y3({ c: 7 }) { |c:| c * 3 })

def two
  yield 1
  yield(k: 2)
end
two { |a, k: 0| p [a, k] }

y3([{ a: 5 }, 3][0]) { |a:| p a }

class Coll
  def initialize(xs) = @xs = xs
  def each(**opts)
    i = 0
    while i < @xs.size
      yield @xs[i], **opts
      i += 1
    end
  end
end
Coll.new([1, 2]).each(sep: "-") { |x, sep: "+"| p [x, sep] }
Coll.new([3]).each { |x, sep: "+"| p [x, sep] }

class Tree
  def initialize = @items = [[1, { tag: :x }], [2, { tag: :y }]]
  def each_tagged
    @items.each { |n, opts| yield n, **opts }
  end
end
Tree.new.each_tagged { |n, tag:| p [n, tag] }

def check(h) = yield(**h)
begin
  check({ z: 1 }) { |k: 1| p k }
rescue ArgumentError => e
  p e.message
end
begin
  check({}) { |k:, j:| p k }
rescue ArgumentError => e
  p e.message
end
check({ z: 1 }) { |c: 7, **r| p [c, r] }
begin
  lit { |c:| p c }
rescue ArgumentError => e
  p e.message
end
