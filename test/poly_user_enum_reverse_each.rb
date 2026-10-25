# spinel: gc-stress
# reverse_each with a block over a user Enumerable read back out of a
# container walks its elements last to first.
def att(name)
  yield
rescue => e
  p [name, e.class, e.message[0, 60]]
end

class Nums
  include Enumerable
  def each; yield 1; yield 2; yield 3; end
end

class Words
  include Enumerable
  def initialize(*w); @w = w; end
  def each(&blk); @w.each(&blk); self; end
end

class Own
  include Enumerable
  def each; yield 1; end
  def reverse_each; yield :own; self; end
end

class Plain
end

n = [Nums.new, 0][0]
att(:yielding) { n.reverse_each { |x| print x }; puts }
att(:result) { p n.reverse_each { |x| x }.equal?(n) }
att(:break) { p(n.reverse_each { |x| break x * 10 if x == 2 }) }
att(:strings) do
  out = []
  [Words.new("a", "b", "c"), 0][0].reverse_each { |x| out << x.upcase }
  p out
end
att(:own) { [Own.new, 0][0].reverse_each { |x| p x } }
att(:plain) { [Plain.new, 0][0].reverse_each { |x| p x } }
att(:array) { [[4, 5], 0][0].reverse_each { |x| print x }; puts }
calls = 0
att(:once) { [(calls += 1; Nums.new), 0][0].reverse_each { |x| print x }; puts; p calls }
class Pairs
  include Enumerable
  def each
    yield 1, 2
    yield 3, 4
    self
  end
end
att(:pairs) do
  got = []
  [Pairs.new, 0][0].reverse_each { |a, b| got << [a, b] }
  [Pairs.new, 0][0].reverse_each { |*r| got << r }
  p got
end
