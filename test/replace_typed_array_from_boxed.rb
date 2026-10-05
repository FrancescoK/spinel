# Array#replace on a typed array that reaches the call untyped takes the
# elements of an array of another kind, as CRuby does.

Point = Struct.new(:x)

def refill(array, source) = array.replace(source)
def pick(array) = ARGV.empty? ? array : "not an array"

ints = [0, 0, 0]
refill(pick(ints), [1, nil, "x"].first(1) + [2, 3])
p ints

holes = [5, 5]
refill(pick(holes), [nil, :a].first(1) + [7])
p holes
p holes.include?(nil)
p holes.count(nil)
p holes.compact

floats = [1.5]
refill(pick(floats), [nil, :a].first(1) + [2.5])
p floats.include?(nil)
p floats.compact

words = ["old"]
refill(pick(words), ["new", 1].first(1) + ["list"])
p words

points = [Point.new(0)]
refill(pick(points), [Point.new(1), 2].first(1) + [Point.new(3)])
p points.map(&:x)

shrink = [9, 9, 9, 9]
refill(pick(shrink), [4, :b].first(1))
p shrink

frozen = [1, 2].freeze
begin
  refill(pick(frozen), [3, :c].first(1))
rescue FrozenError => e
  puts e.class
end
p frozen

locked = [1, 2].freeze
begin
  refill(pick(locked), ["x", 1].first(1))
rescue => e
  puts e.class
end

nul = ["old"]
buf = +"a"
buf << "\0b"
refill(pick(nul), [buf, 1].first(1))
p nul
p nul.first.bytesize

bin = ["old"]
raw = "é".b
raw << "x"
refill(pick(bin), [raw, 1].first(1))
p bin.first.length
p bin.first.encoding
