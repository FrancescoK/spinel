# A program that reopens Enumerable with methods of its own still gets the
# builtin Enumerable methods for Array and Hash, when only some other class
# defines a method of a builtin's name (activesupport's core_ext/enumerable.rb
# beside classes with their own select / partition).
module Enumerable
  def many? = count > 1
end
class Shelf
  def partition = :own
  def each_with_object(x) = [:own, x]
end
p [1, 2, 3, 4].partition(&:odd?), Shelf.new.partition
p({ a: 1, b: 2 }.each_with_object([]) { |(k, v), acc| acc << [v, k] })
p Shelf.new.each_with_object(1)
