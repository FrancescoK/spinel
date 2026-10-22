# A prepended Enumerable is in front of the class itself, also on an Array
# subclass whose reader has the name of one of its methods: the call is
# Enumerable's, and the reader answers where nothing is prepended.
class Prepended < Array
  attr_reader :map
  prepend Enumerable
  def initialize; super; @map = 5; end
end

class Plain < Array
  attr_reader :map
  def initialize; super; @map = 5; end
end

a = Prepended.new
a << 3
p a.map { |x| x * 2 }
b = Plain.new
b << 3
p b.map

# A module doing prepend Enumerable puts Enumerable ahead of its own map.
module ModulePrependedEnumerable
  prepend Enumerable
  def map = :own_map
end
class ModulePrependedCollection
  include ModulePrependedEnumerable
  def each
    yield 1
    yield 2
  end
end
p ModulePrependedCollection.new.map { |x| x * 2 }
