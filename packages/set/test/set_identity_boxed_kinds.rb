# Boxed values entering and looked up in an identity Set: program objects,
# Symbols, nil, true and Strings made afresh (a dup, a unary plus, an
# interpolation), all one object here as in CRuby. Two Strings of the same
# text are two members, a third String of that text is none of them, a
# member String keeps its identity when it changes afterwards, and the Set
# keeps the String it was handed rather than a frozen copy.
require "set"

class Item
  attr_reader :label
  def initialize(label) = @label = label
  def inspect = "#<Item #{@label}>"
end

class Registry
  def initialize = @seen = Set.new.compare_by_identity
  def take(values)
    values.each { |v| @seen << v }
    @seen.size
  end
  def has?(v) = @seen.include?(v)
  def drop(v) = @seen.delete(v).size
  def first_new(v) = @seen.add?(v) ? :added : :present
  def members = @seen.to_a
end

def pick(list, i) = list[i]

a = "x".dup
b = +"x"
c = "#{a}"
one = Item.new(1)
two = Item.new(1)
box = [one, :sym, nil, a, b, true]
r = Registry.new
p r.take(box)
p r.take(box)
p r.has?(a), r.has?(b), r.has?(c), r.has?(one), r.has?(two), r.has?(:sym), r.has?(nil)
p r.first_new(two), r.first_new(pick(box, 0)), r.first_new(c)
p r.members.map(&:class)
p r.members[3].equal?(a), r.members[3].frozen?
a << "!"
p r.has?(a), r.members[3]
p r.drop(pick(box, 4)), r.has?(b), r.has?(a)
