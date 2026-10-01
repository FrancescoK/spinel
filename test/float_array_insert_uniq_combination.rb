# A Float Array answers insert, uniq! and the block forms of combination,
# permutation, repeated_combination and repeated_permutation, as an Integer
# Array does. They raised NoMethodError: the typed dispatch knew them only
# for Integer and String Arrays, and the boxed one only had insert.

a = [3.5, 1.5]
a.insert(1, 7.5)
p a
a.insert(-1, 0.5, 0.25)
p a
b = [1.5]
b.insert(3, 2.5)
p b, b[1].nil?
c = [1.5]
p(c.insert(1, 2.5).equal?(c))
begin
  [1.5].insert(-3, 1.0)
rescue IndexError => e
  puts e.message
end

d = [1.5, 2.5, 1.5, 0.5, 2.5]
p d.uniq!
p d
p d.uniq!
e = [1.5, nil, nil]
e.uniq!
p e

f = [3.5, 1.5, 2.5]
r = []
p f.combination(2) { |q| r << q.sum }
p r
f.permutation(2) { |q| print q.inspect, " " }
puts
p f.repeated_combination(1) { |q| p q }
f.repeated_permutation(1) { |q| print q.first + 1, " " }
puts
[1.5, nil].combination(1) { |q| p q }
