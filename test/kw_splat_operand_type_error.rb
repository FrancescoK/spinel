# A `**` operand is converted to a Hash before any keyword is bound or
# checked: nil carries no keywords, an object answering #to_hash converts,
# and anything else is a TypeError -- for a method's named keywords, its
# **rest, and a Struct or Data constructor alike.
class Opts
  def to_hash = { a: 5, b: 6 }
end
class Foo; end

def k(a: 0, b: 0) = [a, b]
def kr(a:, b: 1) = [a, b]
def rest(**kw) = kw
def both(a: 0, **kw) = [a, kw]
Plain = Struct.new(:a, :b)
Named = Struct.new(:a, :b, keyword_init: true)
Point = Data.define(:x, :y)

def try
  p yield
rescue ArgumentError, TypeError => e
  puts "#{e.class}: #{e.message}"
end

try { k(**1) }
try { k(**"s") }
try { kr(**[1]) }
try { k(**:sym) }
try { k(**1.5) }
try { k(**Foo.new) }
try { rest(**1) }
try { both(**"s") }
try { Plain.new(**1) }
try { Named.new(**"s") }
try { Point.new(**[1]) }

# the operand is evaluated before it raises
$ran = 0
def one
  $ran += 1
  1
end
try { k(**one) }
p $ran

# a boxed operand is checked when the call runs
[{ a: 1 }, 5, nil].each do |v|
  try { k(**v) }
  try { Plain.new(**v) }
end
[{ x: 1, y: 2 }, "no"].each do |v|
  try { Point.new(**v) }
end

# the operand converts at its place among the arguments: a literal before it
# runs, one after it does not
def lit(v) = (puts "lit #{v}"; v)
try { Point.new(x: lit(1), **one) }
try { Point.new(**one, y: lit(2)) }

# beside a literal key naming no member, the operand's TypeError comes first,
# at its place: a literal before it runs, one after it does not
try { Named.new(z: 1, **1) }
try { Plain.new(z: 1, **1) }
try { Point.new(z: 1, **1) }
try { Plain.new(z: lit(9), **one, w: lit(8)) }
[{ b: 2 }, 3].each do |v|
  try { Named.new(c: lit(1), **v) }
end

# keyword_init: false converts the operand too, and a later operand into a
# **kw rest raises where it stands
KwF = Struct.new(:a, :b, keyword_init: false)
try { KwF.new(z: 1, **1) }
h2 = { a: 1 }
try { rest(**h2, **1) }
try { rest(**h2, **nil) }

# nil and #to_hash are unchanged
try { k(**nil) }
try { rest(**nil) }
try { both(**nil) }
try { Plain.new(**nil) }
try { Named.new(**nil) }
try { Point.new(**nil) }
try { k(**Opts.new) }
try { rest(**Opts.new) }
try { Plain.new(**Opts.new) }
