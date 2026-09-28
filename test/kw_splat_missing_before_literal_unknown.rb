# A literal keyword naming no member is judged in CRuby's order: a Data
# member no key names is missing ahead of any unknown key. Beside a `**` that
# is known only at run time, with the keys the operands bring, and the
# unknown keys are named together, literal and operand alike, in source
# order. A String key names a member as a Symbol does; a Data key that is
# neither is a TypeError. Every argument runs first, and an operand that is
# not a Hash raises TypeError where it stands.
Point = Data.define(:x, :y)
Named = Struct.new(:a, :b, keyword_init: true)
Plain = Struct.new(:a, :b)

def lit(v) = (puts "lit #{v}"; v)
def hx = (puts "hx"; { x: 1 })
def full = { x: 1, y: 2 }
def extra = { w: 2, x: 1, y: 2 }
def none = {}
def ha = { a: 1 }

def try
  p yield
rescue ArgumentError, TypeError => e
  puts "#{e.class}: #{e.message}"
end

try { Point.new(z: lit(1), **hx) }
try { Point.new(**hx, z: lit(1)) }
try { Point.new(z: 1, w: 2, **hx) }
try { Point.new(z: 1, **none) }
try { Point.new(z: 1, **full) }
try { Point.new(z: 1, **extra) }
try { Point.new(z: lit(1), **1) }
try { Named.new(z: 1, **{ w: 2 }) }
try { Named.new(**{ w: 2 }, z: 1) }
try { Named.new(z: 1, a: 2, **none) }
try { Named.new(z: lit(1), **1) }
try { Plain.new(z: 1, **{ b: 2 }) }
try { Plain.new(a: 1, z: 2, **none) }
# String keys, from an operand or written
try { Named.new(z: 1, **{ "s" => 1 }) }
try { Named.new(a: 1, **{ "b" => 1 }) }
try { Named.new(**{ "a" => 1 }) }
try { Plain.new(a: 1, **{ "s" => 2 }) }
try { Point.new(x: 1, **{ "y" => 2 }) }
try { Point.new(**{ "x" => 1, "y" => 2 }) }
try { Point.new(x: 1, y: 2, **{ "s" => 2 }) }
try { Point.new(x: 1, y: 2, z: 3, **{ "s" => 2 }) }
try { Point.new(z: 1, **{ "s" => 2 }) }
try { Point.new(x: 1, **{ y: 4, "y" => 3 }) }
try { Point.new(x: 1, **{ "y" => 3, y: 4 }) }
try { Point.new(x: 1, **{ 1 => 2 }) }
try { Named.new("q" => lit(1), **ha) }
try { Point.new("q" => 1, **full) }
# no `**`: decided statically, a Data's missing member first
try { Point.new(z: lit(1), w: lit(2)) }
try { Point.new(x: 1, z: 3) }
try { Point.new(x: 1, y: 2, z: 3) }
try { Named.new(z: 1) }
