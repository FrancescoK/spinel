# A def_delegators forward of each hands the caller's block on: a class
# that delegates each and includes Enumerable answers Enumerable's methods
# over the target, and each itself takes its block, or answers an
# Enumerator without one. The other delegated names take no block.
require "forwardable"
class Bag
  extend Forwardable
  include Enumerable
  def_delegators :@a, :each, :size, :join, :<<, :first, :index
  def_delegator :@a, :last, :tail
  def_delegators :@h, :each_pair
  def initialize = (@a = [3, 1, 2]; @h = {a: 1})
end
q = Bag.new
q << 5
p q.sort, q.map { |x| x * 2 }, q.to_a, q.include?(1), q.count, q.min, q.select(&:odd?)
p q.sort { |a, b| b <=> a }, q.count { |x| x > 1 }, q.size, q.join("-"), q.first(2), q.tail, q.index(1)
r = []
q.each { |x| r << x }
p r, q.each.class, q.each_with_index.to_a.last, q.reduce(:+)
q.each_pair { |k, v| p [k, v] }
