# `&:name` is lowered on Prism's tree to the block it stands for, not
# rewritten in the source text: a `&:name` inside a regexp literal stays the
# regexp's text, the block argument of a command call nested in an argument
# list binds to that call, `super(&:name)` passes no arguments, the lines
# after a block argument written over several lines keep their numbers, a
# name past ASCII is lowered like any other, and a setter Symbol (`&:v=`),
# which is not lowered, calls the setter with what the block is given.
def tag(x, &blk) = blk ? blk.call(x) : [:no_block, x]

p "a&:b".match?(%r{&:b})
p "x&:y z&:y".scan(%r{\w&:y})
p "a&:b" =~ /&:b/

p(tag :a, &:to_s)
p tag :c, &:to_s
p [tag(:b, &:to_s)]
p [1, -2].map(&:-@)

class Base
  def go(*a, &b) = [a, b ? b.call(7) : nil]
end
class Kid < Base
  def go(x) = super(&:succ)
end
p Kid.new.go(1)

def m(a) = yield(a)
x = m(1,
  &:succ)
p x
p __LINE__

class Integer
  def café = self + 1
end
p [1, 2].map(&:café)

class Slot; attr_accessor :v; end
def give = yield(Slot.new, 5)
p give(&:v=)
slots = [Slot.new, Slot.new]
slots.each_with_index(&:v=)
p slots.map(&:v)
