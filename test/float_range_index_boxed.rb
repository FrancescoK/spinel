# A boxed Float Range as the index of an Array or a String, or a Float
# Range indexing a boxed one, converts each end with to_int.

def pick(a, b)
  rand < 2 ? a : b
end

x = pick(1.5..2, 1)
b = [1, 2, 3, 4]
p b[x]
p b.slice(x)
p b.values_at(x)
p ["a", 1, :c][x]
p "abcd"[x]
c = [1, 2, 3, 4]
p c.slice!(x)
p c
c = [1, 2, 3, 4]
c[x] = [9]
p c

y = pick([1, 2, 3, 4], "s")
r = 0.5..1.5
p y[r]
p y[0.5..1.5]
p y[(2.5..)]
z = pick("abcd", [1])
p z[0.5..1.5]
p z[r]
p pick(:abcd, 1)[r]
