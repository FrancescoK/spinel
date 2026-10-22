# A program that makes a Set compare by identity may write a new plain Set
# into the place that held it by reflection, `instance_variable_set(:@s,
# Set.new)`, `Set[...]`, or the same in parentheses after another
# statement: the place then holds a Set made there, as after `@s =
# Set.new`, and other Sets of the program keep their String members.
require "set"

class H
  def initialize = @s = Set.new.compare_by_identity
  attr_reader :s
end

h = H.new
x = 0
h.instance_variable_set(:@s, Set.new)
p h.s.size, h.s.compare_by_identity?
h.instance_variable_set(:@s, Set[1, 2])
p h.s.size
h.instance_variable_set(:@s, (x += 1; Set.new))
p h.s.compare_by_identity?, x
t = Set.new
t << "str"
t << "str"
p t.size
