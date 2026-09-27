# A literal keyword naming no member raises CRuby's ArgumentError once every
# argument is evaluated, in source order: a Struct that takes keywords (a
# plain one called with keywords alone, or keyword_init: true) names each
# such key as `unknown keywords: z, w`, a Data as `unknown keyword: :z`.
Plain = Struct.new(:a, :b)
Opts = Struct.new(:a, :b, keyword_init: true)
Point = Data.define(:x, :y)
Pair = Struct.new(:a, :b)
PlainS = Struct.new(:a, :b)
OptsS = Struct.new(:a, :b, keyword_init: true)
PointS = Data.define(:x, :y)

def lit(v) = (puts "lit #{v}"; v)

$calls = 0
def counted
  $calls += 1
  {}
end

def try
  p yield
rescue ArgumentError => e
  puts "ArgumentError: #{e.message}"
end

try { Plain.new(a: lit(1), z: lit(9)) }
try { Plain.new(z: lit(9), a: lit(1)) }
try { Plain.new(a: 1, z: 9, w: 8) }
try { Plain.new(a: 1, b: 2, c: 3) }
try { Plain.new(z: 1, w: 2, z: 3) }
try { Opts.new(a: lit(1), c: lit(3)) }
try { Opts.new(a: 1, c: 3, d: 4) }
try { Point.new(x: lit(1), y: lit(2), z: lit(9)) }
try { Point.new(x: 1, y: 2, z: 9, w: 8) }

# a `**h` beside the unknown literal key is evaluated too, once
try { PlainS.new(z: 1, **counted) }
try { OptsS.new(c: 1, **counted) }
try { PointS.new(x: 1, y: 2, z: 3, **counted) }
p $calls

# a key that is no plain identifier: escaped into the message, and inspected
# (quoted) by a Data
try { Plain.new(:"a\"b" => 1) }
try { Plain.new(:"a\\b" => 1) }
try { Opts.new(:"a\"b" => 1) }
try { Point.new(x: 1, y: 2, :"q\"z" => 3) }

# a computed key runs before its value and before the raise
def key(k) = (puts "key #{k}"; k)
try { Plain.new(key(:a) => 1, z: 2) }
try { Opts.new(key(:a) => 1, c: 2) }
begin
  Plain.new((raise "key") => 1, z: 2)
rescue RuntimeError => e
  puts "RuntimeError: #{e.message}"
end

# valid constructions, unchanged
try { Plain.new(a: 1) }
try { Plain.new(b: 2, a: 1) }
try { Pair.new(1, b: 2) }
try { Opts.new(b: 2, a: 1) }
try { Point.new(y: 2, x: 1) }
