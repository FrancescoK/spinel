# spinel: int64
# A multiple assignment of Integer literals into locals a loop later grows
# (`a, b = 0, 1` ahead of `c = a + b`): under --int-overflow=promote the
# locals are Bignums, and the stored elements wrap as a plain write's value
# does. The raw sp_int temps went into the sp_Bigint slots and the C did
# not build (#9537). fib(90) fits 64 bits, so every build answers the same.
def fib(n)
  a, b = 0, 1
  n.times do
    c = a + b
    a = b
    b = c
  end
  a
end

p fib(90)

# the same shape with three targets and a swap
def tri(n)
  x, y, z = 1, 1, 1
  n.times do
    x, y, z = y, z, x + y + z
  end
  z
end
p tri(60)
