e = Enumerator.new { |y| y.yield(1, 2, 3); y << 9 }
p e.map { |a, b| [a, b] }
p e.each { |a, b| }.class

e1 = Enumerator.new { |y| y << 1; 42 }
p e1.each { |x| }
r = e1.each { |x| x }
p r
p Enumerator.new { |y| y << 1; :done }.each { |x| }
p Enumerator.new { |y| y << 1 << 2 }.each { |x| }.class
e2 = Enumerator.new { |y| [1, 2].each { |v| y << v } }
p e2.each { |x| }

runs = 0
e3 = Enumerator.new { |y| runs += 1; y << 1; y << 2; "s" }
w = e3.each do |x|
  x
end
p w, runs
p e3.each_with_index { |x, i| }
p e3.each { |x| break 7 if x > 5 }
p e3.each { |x| break 7 if x > 1 }
p e3.each_with_index { |x, i| break i if x > 5 }

def f(o) = o.each { |x| }
p f(e1)
p f([1, 2].each)

p [1, 2].each.each { |x| }
p [3, 4].each_slice(1).each { |x| }
p({ a: 1 }.each.each { |k, v| })
p [1, 2].cycle.each { |x| break x * 10 if x == 2 }
