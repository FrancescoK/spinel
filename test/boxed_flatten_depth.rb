# flatten on an Array or Hash read out of a mixed Array: a depth unwraps
# that many levels (a negative one all), and a Hash flattens its pairs one
# level by default, as Hash#flatten does.
a = [[3, [1, [2]]], :a][0]
p a.flatten
p a.flatten(0)
p a.flatten(1)
p a.flatten(2)
p a.flatten(-1)
n = 1
p a.flatten(n)
h = [{a: [1, [2]], b: 3}, 1][0]
p h.flatten
p h.flatten(0)
p h.flatten(2)
p h.flatten(-1)
p a.flatten(1).size
begin
  [5, :a][0].flatten(1)
rescue NoMethodError => e
  puts e.message
end
