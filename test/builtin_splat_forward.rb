# A delegator's splat into a builtin (`def first(*args, &block) = @a.first(*args,
# &block)`, what Forwardable's def_delegators writes) takes the builtin's arity
# by the rest parameter's size, CRuby's ArgumentError past it.
class Box
  def initialize(a) = @a = a
  def first(*args) = @a.first(*args)
  def include?(*args) = @a.include?(*args)
  def push(*args) = @a.push(*args)
  def fetch(*args, &block) = @a.fetch(*args, &block)
  def index(*args, &block) = @a.index(*args, &block)
  def sum(*args, &block) = @a.sum(*args, &block)
end
b = Box.new([5, 6, 7])
p b.first, b.first(2), b.include?(6), b.push(8, 9).size
p b.fetch(1), b.fetch(10, :d), b.fetch(10) { |i| i * 2 }
p b.index(7), b.index { |x| x > 5 }
p b.sum, b.sum(1), b.sum { |x| x * 2 }
begin
  b.first(1, 2)
rescue ArgumentError => e
  puts e.message
end
begin
  b.fetch
rescue ArgumentError => e
  puts e.message
end
