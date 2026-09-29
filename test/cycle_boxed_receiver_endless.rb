def f(o) = o.cycle.first(3)
p f([1, 2])
p f(1..2)

def g(o)
  c = o.cycle
  p c.class
  p c.first(3)
  p c.take(3)
  p c.first
  p c.next
  p c.next
  p c.next
  p c.lazy.map { |x| [x] }.first(3)
  p o.cycle.find { |x| x != o.first }
  p o.cycle.take_while { |x| x == o.first }
  p o.cycle.include?(o.first)
  p o.cycle.with_index.first(3)
  r = []
  o.cycle.each_with_index { |x, i| break if i > 2; r << x }
  p r
end
g([1, 2])
g(1..2)
g({ a: 1, b: 2 })
g(Enumerator.new { |y| y << :x; y << :y })

begin
  f(5)
rescue NoMethodError => e
  puts e.message
end

def endless_cycle(o) = o.cycle.first(3)
p endless_cycle([1, 2])
p endless_cycle(Enumerator.new { |y| i = 0; loop { y << (i += 1) } })
c = Enumerator.new { |y| y << :a; y << :b }
def cyc(o) = o.cycle
cc = cyc(c)
p cc.next, cc.next, cc.next
p cyc([3]).first(2)
