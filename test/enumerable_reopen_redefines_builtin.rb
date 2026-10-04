# A program's Enumerable reopening that redefines a builtin name answers
# for its includers with its own method.
module Enumerable
  def my_sum = reduce(0) { |a, b| a + b }
  def max_by = "mine"
end
class Bag
  include Enumerable
  def initialize(*a) = @a = a
  def each(&b) = @a.each(&b)
end
p Bag.new(1, 2, 3).my_sum
p Bag.new(1, 5, 3).max_by
