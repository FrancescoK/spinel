# count, any?, all?, none? and one? with a value: CRuby does not call the
# block and counts or tests by the value.

p [3, 2].count(2) { false }
p [3, 2, 2].count(2) { |x| raise "not called" }
p [3, 2].any?(2) { false }
p [3, 2].all?(2) { true }
p [3, 2].none?(2) { false }
p [3, 2].one?(2) { false }
p [1.5, 2.5].count(1.5) { false }
p %w[a b a].count("a") { false }
p %w[a b].any?("c") { true }
m = [1, "a", nil, 1]
p m.count(1) { false }
p m.count(nil) { true }
p m.any?(String) { false }
p((1..4).count(2) { false })
p((1..4).any?(9) { true })
p({a: 1}.count([:a, 1]) { false })
p({a: 1}.any?([:a, 1]) { false })
p [3, 2].each.count(2) { false }
p [3, 2].each_slice(1).count([2]) { false }
p "abca".count("a") { false }

# a block-pass: the expression runs once, the block is not called
b = proc { |x| x > 2 }
p [3, 2].count(2, &b)
p [3, 2].any?(2, &b)
def mk = (puts "made"; proc { true })
p [3, 2].count(2, &mk)
p [3, 2].none?(2, &mk)
p [3, 2].count(2, &:odd?)
p [3, 2].count(2, &nil)

# an Enumerable class of the program's
class Bag
  include Enumerable
  def initialize(*x) = @x = x
  def each(&) = @x.each(&)
end
p Bag.new(5, 7, 7).count(7) { false }
p Bag.new(5, 7).any?(9) { true }

# in a method, a loop and a runtime-name send
def cnt(a, v) = a.count(v) { |x| x > 0 }
p cnt([0, 1, 0], 0)
[[1, 2], [2, 2]].each { |a| p a.count(2) { false } }
p [3, 2].public_send(:count, 2) { false }
