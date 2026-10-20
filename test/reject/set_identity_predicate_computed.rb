# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# The test of a predicate one class answers by a computed value tells
# nothing of the classes that pass it: under `item.pair?` the parts may
# still be a Num's Float, so the identity Set's member is refused at
# compile time.
require "set"

class Item
  def pair? = false
end

class Pair < Item
  def initialize(first) = @first = first
  def parts = [@first]
  def pair? = true
end

class Num < Item
  def initialize(value) = @value = value
  def parts = [@value]
  def pair? = @value.is_a?(Float)
end

seen = Set.new.compare_by_identity
[Pair.new(Item.new), Num.new(0.5)].each do |item|
  item.parts.each { |v| seen << v } if item.pair?
end
p seen.size
