nat = Enumerator.new { |y| i = 0; loop { y << (i += 1) } }
p nat.each_slice(2).first
p nat.each_with_index.first(2)
p nat.each_slice(2).first(2)
p nat.each_cons(2).first(2)
s = nat.each_slice(3)
p s.next, s.next
p s.first(2)
p Enumerator.new { |y| i = 0; loop { y << (i += 1) } }.each_slice(2).first(2)
p nat.each_slice(2).lazy.map { |a| a.sum }.first(2)
p [1, 2].cycle.each_slice(3).first(2)
p [1, 2].cycle.each_with_index.first(3)

fin = Enumerator.new { |y| y << 1; y << 2; y << 3 }
p fin.each_slice(2).to_a
p fin.each_cons(2).to_a
p fin.each_with_index.to_a
p fin.each_slice(2).size
pk = Enumerator.new { |y| y.yield 1, 2; y << 3; y << 4 }
p pk.each_slice(2).to_a
p pk.each_with_index.to_a
begin
  fin.each_slice(0)
rescue ArgumentError => e
  p e.message
end

def f(o) = o.each_slice(2).first(2)
p f(nat)
p f([1, 2, 3])
p f(1..)
def f2(o) = o.each_cons(2).first(2)
p f2(nat)
p f2([1, 2, 3])
def g(o) = o.each_with_index.first(2)
p g(nat)
p g([5, 6])
p g(1..)
