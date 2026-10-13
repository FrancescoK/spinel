# An attribute write through a boxed receiver (two Structs share the member)
# whose value is an Integer or a Float that may be nil: the member gets the
# nil itself, and the write's value is that nilable number (#8769).
A = Struct.new(:val)
B = Struct.new(:val)

def f(s, x)
  y = x ? 1.0 : nil
  if x
    s.val = y
  end
end

def g(s, x)
  y = x ? 3 : nil
  s.val = y
end

puts f(A.new, true).inspect
puts f(B.new, true).inspect
puts f(A.new, false).inspect
a = A.new(5)
p g(a, false), a.val
b = B.new(5)
p g(b, true), b.val
