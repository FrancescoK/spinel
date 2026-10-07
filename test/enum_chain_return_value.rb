# An Enumerator chain run with a block answers what the chain's each answers

p 2.times.each { }
n = 3
x = n.times.each { |i| print i }
puts
p x

s = "ab"
p s.each_char.with_index { }
r = s.each_char.with_index(1) { |c, i| print c, i }
puts
p r
@s = "xyz"
p @s.each_char.with_index { |c, i| }
s.each_char.with_index { |c, i| print c, i }
puts

def f(a) = a.each.with_index { }
p f([1, 2])

def g(a)
  a.each.with_index { |v, i| print v, i }
end
p g([:a])

def h(a)
  a.each.with_index(1) { |v, i| }
end
p h(%w[q])
