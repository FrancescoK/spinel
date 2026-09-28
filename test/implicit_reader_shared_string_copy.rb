# A receiverless reader of a shared-mutable String slot reads out as a copy
# in a plain string context, as `self.v` does: `v.dup` and `v.upcase` in the
# class's own methods passed the raw handle to the String helpers and the C
# did not build.
class G
  attr_accessor :v
  def initialize(v) = @v = v
  def up = v.upcase
  def cp = v.dup
  def cp2 = @v.dup
  def cp3 = self.v.dup
  def copy = self.class.new(v.dup)
end
g = G.new(+"x")
g.v << "y"
p g.up, g.cp, g.cp2, g.cp3
c = g.cp
c << "z"
p g.v, c
d = g.copy
d.v << "w"
p g.v, d.v
