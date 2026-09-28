# A Struct taking keywords binds a key that is not a Symbol or a String as a
# member index, as CRuby's rb_struct_pos does: converted as an Integer
# argument is (a Float truncates, nil is a TypeError), counted from the end
# when negative, and named in `unknown keywords` when out of range. Such a key
# was unknown beside a `**`, and dropped when written. A Data takes Symbols
# and Strings alone: any other key is a TypeError. A bare `new` in the
# class's own methods binds them alike.
Named = Struct.new(:a, :b, keyword_init: true)
Plain = Struct.new(:a, :b)
Point = Data.define(:x, :y)
Loose = Struct.new(:a, :b, keyword_init: false)

class Index
  def to_int = 1
end

def lit(v) = (puts "lit #{v}"; v)

def try
  p yield
rescue ArgumentError, TypeError => e
  puts "#{e.class}: #{e.message}"
end

try { Named.new(a: 1, **{ 1 => 2 }) }
try { Named.new(**{ 0 => 1, 1 => 2 }) }
try { Named.new(**{ -1 => 2 }) }
try { Named.new(**{ -2 => 2 }) }
try { Named.new(**{ -3 => 2 }) }
try { Named.new(**{ 2 => 2 }) }
try { Named.new(**{ 5 => 2, z: 1 }) }
try { Named.new(**{ z: 1, 5 => 2 }) }
try { Named.new(**{ z: 1, 1 => 2 }) }
try { Plain.new(a: 1, **{ 1 => 2 }) }
try { Plain.new(**{ -1 => 2 }) }
try { Plain.new(**{ 5 => 2 }) }

# the last key naming a member wins, by name or by index
try { Named.new(**{ -2 => 1, a: 3 }) }
try { Named.new(**{ a: 3, -2 => 1 }) }
try { Named.new(a: 3, **{ 0 => 1 }, b: 4) }
try { Named.new(**{ 1 => 5 }, b: 4) }

# written, evaluated in source order
try { Named.new(lit(1) => lit(2), a: lit(3)) }
try { Named.new(1 => 2) }
try { Named.new(b: 7, 0 => 5) }
try { Named.new(5 => 2) }
try { Named.new(z: 1, 5 => 2) }
try { Plain.new(1 => 2, a: 1) }
try { Plain.new(-2 => 2) }

# converted as an Integer argument
try { Named.new(1.9 => 2) }
try { Named.new(-2.5 => 2) }
try { Named.new(3.5 => 2, z: 1) }
try { Named.new(Index.new => 2) }
try { Named.new(**{ Index.new => 2 }) }
try { Named.new(**{ z: 1, nil => 2 }) }
try { Named.new(true => 2) }

# a Data takes none, and a keyword_init: false Struct keeps it in its Hash
try { Point.new(x: 1, **{ 1 => 2 }) }
try { Point.new(1 => 2, x: 1) }
try { Point.new(x: lit(1), 1 => lit(2), y: lit(3)) }
try { Loose.new(1 => 2) }
try { Loose.new(1 => 2, **{ b: 3 }) }

# the member takes the value's class, nil when no key names it
p Named.new(1 => "s").b.upcase
p Named.new(1 => 2.5).b + 1
p Named.new(0 => 1).b

# a bare `new` in the class's own methods
Made = Struct.new(:a, :b, keyword_init: true) do
  def self.index = new(1 => "s")
  def self.over(h) = new(a: 1, **h)
end
MadePoint = Data.define(:x, :y) do
  def self.index = new(x: 1, 1 => 2)
end
try { Made.index }
try { Made.over({ -1 => 2 }) }
try { Made.over({ 2 => 2 }) }
try { MadePoint.index }

# a key converts once per construction, as a #to_int that counts sees
class Counting
  def initialize = (@n = 0)
  def to_int = (@n += 1) - 1
end
try { Named.new(**{ Counting.new => 5 }) }
try { Named.new(Counting.new => 5) }
try { Plain.new(**{ Counting.new => 5, b: 2 }) }
counter = Counting.new
try { Named.new(**{ counter => 5, Counting.new => 6 }) }
p counter.to_int
try { Named.new(**{ "a" => 1, 0 => 2, a: 3 }) }
try { Named.new(**{ 0 => 1, "a" => 2 }) }
Box = Struct.new(:a, :b, keyword_init: true)
p Box.new(1 => []).b.push(6)
