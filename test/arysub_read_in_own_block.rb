# A read of an Array, Hash or String subclass instance inside the block of
# an iterator called on the same instance.

class A < Array; end
class H < Hash; end
class S < String; end

a = A.new([1, 2, 3])
s = 0
a.each_index { |i| s += a[i] + 1 }
p s
a.each_with_index { |e, i| p a[i] + e }
a.each_index { |i| p a.fetch(i) * 2 }
p a.map { |e| a[0] + e }
p a.select { |e| a.first < e }
p a.sum { |e| a[e - 1] }
p a.each_slice(2).map { |sl| sl.size + a.size }
t = 0
a.each { |e| a.each { |f| t += e * f + a[0] } }
p t

h = H.new
h[:x] = 1
h[:y] = 2
h.each { |k, v| p h[k] + v }
p h.map { |k, v| h.size + v }

w = S.new("abc")
w.each_char { |ch| p w.index(ch) + 1 }
