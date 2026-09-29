e = Enumerator.new { |y| y.yield(*[]) }
p e.map { |*r| r }
p e.to_a
p e.map { |x| x }

xs = []
e2 = Enumerator.new { |y| y.yield(*xs); y.yield(*[1]); y.yield(*[1, 2]) }
p e2.map { |*r| r }
p e2.to_a

e3 = Enumerator.new { |y| y.yield; y.yield 1 }
p e3.map { |*r| r }
p e3.to_a
p e3.next

e4 = Enumerator.new { |y| y.yield(*[]); y.yield(1, 2) }
p e4.map { |*r| r }
p e4.to_a

def f(o) = o.map { |*r| r }
p f(e)
p f(e4)

e5 = Enumerator.new { |y| y.yield; y.yield(*[]); y.yield 3 }
e5.each { |*a| p a }
e5.each { |a| p a }
x = e5.next
p x.nil?, x == nil, { x => 1 }[nil]
p e5.first(2)
p e5.each_slice(2).to_a
p e5.with_index.map { |*r| r }
p e5.count

def g(o)
  o.each { |*a| p a }
  o.map { |a| a }
end
p g(e5)
