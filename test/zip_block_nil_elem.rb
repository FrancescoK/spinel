# A zip block's parameters see a nil element of an Integer or Float Array
# as nil, the receiver's as well as each argument's.
def ints(s)
  a = s.bytes
  a[3] = 1
  a.zip(a) { |x, y| p [x, y] }
end

ints("ab")
a = "ab".bytes
a[3] = 1
a.zip(a) { |x, y| p [x, y] }
a.zip(a) { |pr| p pr }
b = [1.5]
b[2] = 2.5
b.zip(b) { |x, y| p [x, y] }
b.zip(a, a) { |x, y, z| p [x, y, z] }
