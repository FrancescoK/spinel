# Array.new copies the container and retains the objects in its elements.
s = +"a"
a = [s]
b = Array.new(a)
b[0] << "!"
p [s, a, b]

# A fresh element keeps its own handle beside an alias in a copied literal.
s = +"ab"
a = Array.new([s, s.dup])
a[0] << "!"
a[1] << "z"
p [s, a]
