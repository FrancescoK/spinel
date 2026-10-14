# In Enumerator.new { |y| ... } driven by each with a block, y.yield answers
# the value of the block it handed the element to (next and break as in any
# block), and each answers the generator's own value.
e = Enumerator.new do |y|
  out = []
  [1, 2, 3].each { |v| out << v if y.yield(v) }
  out
end
p e.each { |x| x < 2 }
p Enumerator.new { |y| y.yield(5) }.each { |x| x * 10 }
p Enumerator.new { |y| y.yield(1, 2) }.each { |a, b| a + b }
gen = Enumerator.new do |y|
  got = []
  [1, 2, 3, 4].each { |v| got << y.yield(v) }
  got
end
p gen.each { |x| next :skip if x == 2; x * 10 }
p gen.each { |x| break :early if x == 3; x }
p gen.each { |x| x.odd? ? "o" : nil }
p gen.each_with_index { |x, i| x + i }
def twice(en) = en.each { |x| x * 2 }
p twice(gen)
gen.each { |x| p x if x > 3 }
p e.next, gen.take(2), [5, 6].each.each { |x| x + 1 }
# the same through to_enum / enum_for of a method that yields: yield answers
# the each block's value
def one
  yield 3
end
def two
  return enum_for(__method__) unless block_given?
  yield(4) + 1
end
p to_enum(:one).each { |x| x * 2 }, two.each { |x| x * 10 }
