# A class-level ivar written an empty array literal and also a value the
# analysis types later (`@defs = defs + [...]`, a cycle through the reader):
# the empty literal alone does not make it an Integer array. A local taken from
# the reader followed that wrong type and the equality on it was refused, or
# the run raised "an Array holding Hash reached a slot typed as an Integer
# Array" (#7602).
class Base
  def self.defs
    @defs
  end

  def self.add
    @defs = defs + [{ keys: ["a", "b"] }]
  end

  def self.clear
    @defs = []
  end

  def self.def_at(i) = defs[i]

  @defs = []
  add
end

class Child < Base
  def self.defs
    @defs.nil? ? Base.defs : @defs
  end
end

parent = Base.defs
p(parent[0][:keys] == ["a", "b"])
p parent.size
p parent.first
p Base.def_at(0)
