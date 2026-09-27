# A direct block call to a yielding method a subclass overrides takes the
# cls_id switch through the proc-form clones.

class A; def m = yield(1); end
class B < A; def m = yield(2); end
A.new.m { |x| p x }
B.new.m { |x| p x }
[A.new, B.new].each { |o| o.m { |x| p x } }
A.new.m { |x| puts "a#{x}" }
p(A.new.m { |x| x + 10 })

class Pair
  def each_twice = (yield 1; yield 2)
  def run = each_twice { |x| puts "run #{x}" }
end
class Triple < Pair
  def each_twice = (yield 1; yield 2; yield 3)
end
Pair.new.each_twice { |x| p x }
Triple.new.each_twice { |x| p x }
Pair.new.run
Triple.new.run

class Scale
  def apply(a, b) = yield(a * b)
end
class Offset < Scale
  def apply(a, b) = yield(a + b)
end
sum = 0
Scale.new.apply(3, 4) { |v| sum += v }
Offset.new.apply(3, 4) { |v| sum += v }
p sum
seen = []
[Scale.new, Offset.new].each { |o| o.apply(2, 5) { |v| seen << v } }
p seen
count = 0
Pair.new.each_twice { |x| count += x }
Triple.new.each_twice { |x| count += x }
p count

# the call answers its own block's value, not another call site's
s = A.new.m { |x| "a#{x}" }
r = A.new.m { |x| x * 5 }
p s, r
v = A.new.m { |x| puts x }
p v
str = "s"
A.new.m { |x| str += x.to_s }
B.new.m { |x| str += x.to_s }
p str
