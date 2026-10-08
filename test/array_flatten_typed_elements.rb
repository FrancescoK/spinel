# Array#flatten on a typed-array-of-typed-array concatenates the inner
# arrays into one flat typed array. Previously only int elements were
# specialized; str and float now mirror it (the pr_geohash gem's
# neighbors does map{...}.flatten over string cells).
# spinel: wasm
ints = [[1, 2], [3, 4]]
p ints.flatten
puts ints.flatten.length

strs = [["a", "b"], ["c", "d"]]
p strs.flatten
puts strs.flatten.length

floats = [[1.0, 2.0], [3.5, 4.5]]
p floats.flatten
puts floats.flatten.length

# Uneven inner lengths and an empty inner array.
mixed = [["x"], [], ["y", "z"]]
p mixed.flatten
