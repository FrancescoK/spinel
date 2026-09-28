# Keywords from several sources -- two `**` operands, or a literal key
# ahead of one -- merge in source order into named keyword params and into a
# Data or Struct constructor, a later key winning, as CRuby binds them. The
# positionals run first, then each value and operand once, where it stands,
# and the missing and unknown keyword checks judge the merged keys. A `**`
# bound to a positional parameter runs once too.
class Opts
  def to_hash = { b: 7 }
end

def k(a: 0, b: 0) = [a, b]
def kr(a:, b:) = [a, b]
def mix(a: 0, **kw) = [a, kw]

Point = Data.define(:x, :y)
KwStruct = Struct.new(:x, :y, keyword_init: true)
PlainStruct = Struct.new(:x, :y)

class C
  def k2(x, a: 0, b: 0) = [x, a, b]
  def pos(h) = h

  def initialize(a: 0, b: 0)
    @a = a
    @b = b
  end

  def pair = [@a, @b]
  def k(a: 0, b: 0) = [a, b]
  def self.k(a: 0, b: 0) = [a, b]
end

def yk(a: 0, b: 0) = yield(a, b)
def k2(x, a: 0, b: 0, &blk) = [x, a, b, blk ? blk.call : nil]
def yk2(x, a: 0, b: 0) = yield(x, a, b)
def pos(h) = h
def rest(*r) = r
def xrest(x, **r) = [x, r]
def pos2(x, h) = [x, h]

class Box
  def initialize(x, a: 0)
    @v = [x, a]
  end

  attr_reader :v
end

def fwd(**) = k(**, **{ b: 8 })

def src(tag, v)
  puts "eval #{tag}"
  v
end

def try
  p yield
rescue ArgumentError, TypeError => e
  puts "#{e.class}: #{e.message}"
end

h = { a: 1 }
g = { b: 2 }
e = {}
boxed = [{ a: 4 }, 1][0]

# two operands, and a literal ahead of one
p k(**h, **g)
p kr(**h, **g)
p C.new.k(**h, **g)
p C.k(**h, **g)
p C.new(**h, **g).pair
p(yk(**h, **g) { |a, b| [a, b] })
p k(**h, **{ a: 9 })
p k(a: 3, **h)
p k(a: 3, **g)
p kr(b: 3, **h)
p k(**h, b: 5, **g)
p fwd(a: 5)

# a lone operand with literals after it, as before
p k(**h, a: 3)
p k(**h, b: 5)

# a **kw rest beside named keywords
p mix(**h, **g)
p mix(**g, **{ a: 5 })
p mix(a: 7, **h)
p mix(z: 1, **h, **g)

# empty, nil, boxed and converted sources
p k(**h, **nil)
p k(**nil, **g)
p k(**{}, **h)
p k(**h, **e)
p k(**boxed, **g)
p k(**g, **boxed)
p k(**h, **Opts.new)

# each operand once, in order
p k(**src(1, h), **src(2, g))
p k(a: src(1, 5), **src(2, h), b: src(3, 6))
p k(**src(1, nil), **src(2, g))
try { k(**src(1, h), **src(2, 1), **src(3, g)) }

# the checks judge the merged keys
try { kr(**{ a: 1 }, **{}) }
try { kr(**e, **g) }
try { k(**h, **{ z: 1 }) }
try { k(**{ y: 1 }, a: 2, **{ z: 1 }) }
try { C.new.k(z: 1, **h) }

# the positionals run ahead of the keywords
p k2(src(1, 1), a: src(2, 2), **src(3, g))
p k2(*src(1, [1]), a: src(2, 2), **src(3, g))
p k2(src(1, 1), **src(2, g), **src(3, h))
p k2(src(1, 1), a: src(2, 2), **src(3, g), &proc { :blk })
p C.new.k2(src(1, 1), a: src(2, 2), **src(3, g))
p(yk2(src(1, 1), a: src(2, 2), **src(3, g)) { |*v| v })
p k2(src(1, 1), **src(2, g))
p k2(src(1, 1), **src(2, g), a: src(3, 2))
p k2(src(1, 1), **src(2, nil))
p k2(*src(1, [1]), **src(2, g))
p k2(src(1, 1), **src(2, g), &proc { :blk })
p C.new.k2(src(1, 1), **src(2, g))
p(yk2(src(1, 1), **src(2, g)) { |*v| v })
p Box.new(src(1, 1), **src(2, h)).v
p xrest(src(1, 1), **src(2, g))
p pos2(src(1, 1), **src(2, g))

# a Data or Struct constructor
hx = { x: 1 }
hy = { y: 2 }
xy = { x: 1, y: 2 }
try { Point.new(**hx, **hy) }
try { Point.new(x: 5, **xy) }
try { Point.new(**xy, x: 5) }
try { Point.new(**hx, **{}) }
try { Point.new(**hx, **{ z: 3 }, **hy) }
try { KwStruct.new(**hx, **hy) }
try { KwStruct.new(x: 5, **xy) }
try { KwStruct.new(**hx, **{ z: 3 }) }
try { PlainStruct.new(**hx, **hy) }
try { PlainStruct.new(x: 5, **xy) }
try { Point.new(**src(1, hx), **src(2, hy)) }
try { KwStruct.new(y: src(1, 9), **src(2, hx), **src(3, nil)) }
try { Point.new(**hx, **src(1, 1), **src(2, hy)) }

# a keyword hash bound to a positional parameter
p pos(**src(1, h))
p rest(**src(1, h))
p pos(**src(1, h), **src(2, g))
p pos(z: 1, **src(1, h))
p C.new.pos(**src(1, h))
