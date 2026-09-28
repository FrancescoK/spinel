# next_float and prev_float on a Float read out of a container answer the
# neighbouring Floats, as a typed Float does; an Integer raises
# NoMethodError.
x = [1.5, 0][0]
p x.next_float
p x.prev_float
z = [0.0, 1][0]
p [z.next_float, z.prev_float]
m = [Float::MAX, 0][0]
p [m.next_float, m.prev_float]
i = [Float::INFINITY, 0][0]
p [i.next_float, i.prev_float]
n = [Float::NAN, 0][0]
p [n.next_float.nan?, n.prev_float.nan?]
p [x.next_float > x, x.prev_float < x]
k = [3, 0.5][0]
begin
  k.next_float
rescue NoMethodError => e
  p [e.message, e.args]
end
