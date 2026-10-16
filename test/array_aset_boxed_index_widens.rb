# A store into an Array parameter whose index the build holds boxed (every
# Integer under --int-overflow=promote) widens a typed Array for a value of
# another kind, as the store with an unboxed index does: it raised "cannot
# store String into an Array[Integer]".
def put(h, i, v)
  h[i] = (h = nil if v == 0; v)
  h
end
p put([1, 2], 0, "y")
p put([1, 2], 0, 2.5)
p put([1, 2], 0, 3)
p put([1.5, 2.5], 1, "z")
p put(%w[a b], 1, 7)
