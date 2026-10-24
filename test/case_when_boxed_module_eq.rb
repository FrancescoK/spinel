# A `when` pattern held boxed whose class takes #=== from a module it
# includes (an alias of the module's #==, or the module's own #===) asks
# that method with the case subject. The module has no instances of its
# own, so the dispatch has no arm for it, only for the classes that
# include it.

module Matching
  def ==(other) = other.respond_to?(:tag) && other.tag == tag
  alias === ==
end

module Pattern
  def ===(other) = other == :wanted
end

module Wrapped
  include Matching
end

class Item
  include Matching
  attr_reader :tag

  def initialize(tag) = @tag = tag
end

class Rule
  include Pattern
end

class Box
  include Wrapped
  attr_reader :tag

  def initialize(tag) = @tag = tag
end

class Choice
  def initialize(i) = @i = i
  def pattern = [Item.new(1), Rule.new, Box.new(2), :plain, 3][@i]
end

def classify(choice, subject)
  case subject
  when choice.pattern then :hit
  else :miss
  end
end

p classify(Choice.new(0), Item.new(1)), classify(Choice.new(0), Item.new(2))
p classify(Choice.new(1), :wanted), classify(Choice.new(1), :other)
p classify(Choice.new(2), Item.new(2)), classify(Choice.new(2), Box.new(5))
p classify(Choice.new(3), :plain), classify(Choice.new(4), 3), classify(Choice.new(4), 4)
