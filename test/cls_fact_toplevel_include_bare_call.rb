# spinel: share
# A module included at top level is Object's, so a bare call of its method
# answers that method's value: the class facts looked up a class's method
# and a top-level def only, so the value held no class of the program's
# and a boxed call on it had no arm for the class it is (NoMethodError).
class Box
  attr_reader :ch
  def initialize(ch) = @ch = ch
end
class Other
  def ch = "o"
end
module Helpers
  def fill(ch) = Box.new(ch)
end
include Helpers

[Other.new, fill("-")].each { |o| puts o.ch }

class Panel
  def draw = fill("x")
end
[Other.new, Panel.new.draw].each { |o| puts o.ch }
