# `members` on a boxed receiver when a class defines `self.members`: a class
# value takes the class-side switch, where that class answers its own
# method and a Struct or Data class with none answers its member names; an
# instance with an attr_reader answers the reader.
class Roster
  attr_reader :members
  def initialize = (@members = [:r])
  def self.members = [:class_side]
end

Point = Struct.new(:x, :y)
Pos = Data.define(:q)

[Roster.new, Roster, Point, Pos, Point.new(1, 2), Pos.new(q: 3)].each { |o| p o.members }
