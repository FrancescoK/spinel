# Array.new(array) builds a copy of the array, whatever its element kind:
# it took the Array.new(size) path and raised TypeError (#7449, which an
# Array subclass's `super(records)` reaches).
ints = [3, 1, 2]
copy = Array.new(ints)
copy << 4
p ints, copy

strs = Array.new(["a", "b"])
strs.push("c")
p strs

floats = Array.new([1.5])
p floats.sum

mixed = Array.new([1, "x", nil])
p mixed, mixed.equal?(mixed.dup)

p Array.new(2), Array.new(2, 0), Array.new(3) { |i| i * i }

# a value known only at run time: a copy of an Array, else that many nils
[[5, 6], 2].each { |v| p Array.new(v) }
