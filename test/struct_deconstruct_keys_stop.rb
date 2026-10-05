# deconstruct_keys on a Struct or Data with a literal key array, as CRuby:
# more keys than members is {}, and the first key naming no member ends
# the hash there (a later member key is not read).
S = Struct.new(:a, :b)
s = S.new(1, 2)
p s.deconstruct_keys([:a])
p s.deconstruct_keys([:b, :a])
p s.deconstruct_keys([:a, :z])
p s.deconstruct_keys([:z, :a])
p s.deconstruct_keys([:a, :b, :a])
p s.deconstruct_keys([])
p s.deconstruct_keys(nil)
Point = Data.define(:x, :y)
pt = Point.new(x: 1, y: 2)
p pt.deconstruct_keys([:x, :nope])
p pt.deconstruct_keys([:nope, :x])
p pt.deconstruct_keys([:x, :y, :x])
case s
in {a: 1, z: _} then p :wrong
in {a: 1} then p :right
end
