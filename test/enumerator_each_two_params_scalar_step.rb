e = Enumerator.new { |y| y.yield 1, 2; y.yield 3; y << [4, 5]; y << "s" }
e.each { |a, b| p [a, b] }
e.each_with_index { |a, i| p [a, i] }

def f(o) = o.each { |a, b| p [a, b] }
f(e)

def g(o)
  o.each { |a, b| p [a, b] }
  nil
end
g(e)
g([[1, 2], 3])

[1, [2, 3], "x"].each.each { |a, b| p [a, b] }
