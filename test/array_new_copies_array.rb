# Array.new with an Array argument is a copy of it: typed (each kind), a
# literal, an empty literal, a boxed Array, and a call the inference widened.
# A boxed Integer still sizes an Array of nils.
p Array.new([1, 2])
a = ["x", "y"]
b = Array.new(a)
b << "z"
p a, b
p Array.new([1, "s"])
p Array.new([])
f = Array.new([1.5, 2.5])
p f.sum
i = 0
pa = [[3, 4], 1][i]
c = Array.new(pa)
c << 5
p c, pa
pn = [2, [1]][i]
p Array.new(pn)
p Array.new(2)
p Array.new(2, 0)
p((Array.new("s") rescue $!.message))
p((Array.new(-1) rescue $!.message))
h = Array.new([[1, 2]]).to_h
p h
m = [nil, 3]
p Array.new(m).compact
p Array.new([[1], [2]])[1][0]
x = Array.new([1, 2])
x = Array.new(["a"]) if rand > 2
x << "q"
p x
