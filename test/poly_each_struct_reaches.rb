# A block over a boxed value that may be a Struct reaches the Struct's each
# Beside test/poly_each_struct_elsewhere.rb: where the receiver's class fact
# holds the Struct, the block still goes through the dispatch, which runs
# the Struct's each for it and the Array walk for an Array.

Point = Struct.new(:x, :y)
pt = Point.new(1, 2)
mixed = [pt, [10, 20]]
def show_all(rows)
  rows.each { |m| m.each { |v| print v, " " } }
end
show_all(mixed)
puts
p mixed.map { |m| m.map { |v| v * 2 } }
total = 0
mixed.each { |m| m.each { |v| total += v } }
p total
