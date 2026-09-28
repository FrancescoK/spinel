# A Data construction whose arguments cannot fill its members evaluates every
# argument first, in order -- a `**` operand too, converting where it
# stands -- and raises CRuby's ArgumentError: positionals beside keywords
# count the keywords as one more argument, positionals alone are too many or
# leave members missing, and keywords alone leave members missing. Keywords
# that are only `**` operands count only when a key comes out of them.
Point = Data.define(:x, :y)
P1 = Data.define(:x)
P0 = Data.define

def s(tag, v) = (puts tag; v)
def none = {}

def try
  p yield
rescue ArgumentError, TypeError => e
  puts "#{e.class}: #{e.message}"
end

try { Point.new(s(:pos, 1), **s(:h, { y: 2 })) }
try { Point.new(s(:pos, 1), y: s(:y, 2)) }
try { Point.new(s(:pos, 1), s(:p2, 2), y: s(:y, 3)) }
try { Point.new(s(:pos, 1), z: s(:z, 2), **s(:h, { y: 2 })) }
try { Point.new(s(:pos, 1), **s(:h, 1)) }
try { Point.new(s(:pos, 1), z: s(:z, 2), **s(:h, 1)) }
try { Point.new(s(:pos, 1), **none) }
try { Point.new(s(:pos, 1), s(:p2, 2), **none) }
try { Point.new(s(:pos, 1), s(:p2, 2), **nil) }
try { Point.new(1, 2, 3, **none) }
try { Point.new(s(:pos, 1)) }
try { Point.new }
try { Point.new(s(:a, 1), s(:b, 2), s(:c, 3)) }
try { P1.new(1, 2) }
try { P0.new(1) }
try { Point.new(x: s(:x, 1)) }
