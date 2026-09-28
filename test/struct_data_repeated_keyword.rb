# A keyword written twice into a Data or Struct constructor binds its last
# value, as CRuby does, and every value is evaluated, in source order. A Data
# given one then has every member (`wrong number of arguments` said it had
# not), and a Struct took the first value without running the second. A key
# a later `**` brings again replaces the literal's value, of whatever class
# (it was read as the literal's, an Integer member reading a String's
# pointer); ahead of the `**` the literal wins. A bare `new` in the class's
# own methods binds them alike.
Point = Data.define(:x, :y)
Named = Struct.new(:a, :b, keyword_init: true)
Plain = Struct.new(:a, :b)

def lit(v) = (puts "lit #{v}"; v)

def try
  p yield
rescue ArgumentError => e
  puts "ArgumentError: #{e.message}"
end

try { Point.new(x: 1, x: 2, y: 3) }
try { Point.new(x: lit(1), y: lit(3), x: lit(2)) }
try { Point.new(x: 1, x: 2) }
try { Point.new(x: lit(1), x: lit(2), z: lit(3)) }
try { Point.new(x: 1, y: 2, y: 3, z: 4) }
try { Named.new(a: lit(1), a: lit(2), b: 3) }
try { Named.new(a: 1, a: 2) }
try { Named.new(a: lit(1), a: lit(2), z: lit(3)) }
try { Plain.new(a: lit(1), a: lit(2), b: 3) }
try { Plain.new(a: 1, a: 2) }

# beside a `**`, ahead of it or after it
try { Point.new(x: lit(1), x: lit(2), **{ y: 3 }) }
try { Point.new(**{ y: 3 }, x: lit(1), x: lit(2)) }
try { Named.new(a: lit(1), a: lit(2), **{ b: 3 }) }
try { Named.new(**{ b: 3 }, a: lit(1), a: lit(2)) }
try { Plain.new(a: lit(1), a: lit(2), **{ b: 3 }) }
try { Plain.new(**{ b: 3 }, a: lit(1), a: lit(2)) }

# the last value is the member's, whatever its class, nil included
p Point.new(x: 1, x: "s", y: 2).x
p Named.new(a: 1, a: "s").a
p Plain.new(a: 1, a: 2.5).a
p Named.new(a: 1, **{ a: nil })
p Point.new(x: 1, **{ y: 2, x: nil })
p Point.new(x: 1, x: 2, y: 3).x + 1

# a later `**` bringing the key again, of another class
Wide = Struct.new(:a, :b, keyword_init: true)
WidePlain = Struct.new(:a, :b)
WidePoint = Data.define(:x, :y)
p Wide.new(a: 1, **{ a: "s" })
p Wide.new(a: 1, **{ b: 2 })
p WidePlain.new(a: 1, **{ a: [1] })
p WidePoint.new(x: 1, **{ y: 2, x: :s })
p WidePoint.new(x: 1, y: 2)

# a `**` ahead of the literal, or a literal after the last `**`: the literal's
Lead = Struct.new(:a, :b, keyword_init: true)
LeadPlain = Struct.new(:a, :b)
LeadPoint = Data.define(:x, :y)
p Lead.new(**{ a: "s" }, a: 1).a + 1
p Lead.new(a: 1, **{ a: "s" }, a: 2).a + 1
p LeadPlain.new(**{ a: "s", b: 2 }, a: 1).a + 1
p LeadPoint.new(**{ x: "s", y: 2 }, x: 1).x + 1

# a bare `new` in the class's own methods
Made = Struct.new(:a, :b, keyword_init: true) do
  def self.twice = new(a: lit(1), a: lit("s"))
  def self.over(h) = new(a: 1, **h)
end
MadePoint = Data.define(:x, :y) do
  def self.twice = new(x: 1, x: 2, y: 3)
  def self.over(h) = new(x: 1, **h)
end
try { Made.twice }
try { Made.over({ a: "t", b: 2 }) }
try { Made.over({ z: 3 }) }
try { MadePoint.twice }
try { MadePoint.over({ y: 2, x: nil }) }
try { MadePoint.over({}) }

# an empty container as the last value takes the container's kind
Bin = Struct.new(:a, keyword_init: true)
BinHash = Struct.new(:a, keyword_init: true)
BinPoint = Data.define(:x)
p Bin.new(a: 1, a: []).a.push(4)
p BinHash.new(a: 1, a: Hash.new).a.size
p BinPoint.new(x: 1, x: []).x.push(5)
