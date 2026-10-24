# spinel: reject-subclass: a method defined in an instance_eval block
# A def in an instance_eval block beside other statements: the block is
# not a reopening of defs only, so the def is refused rather than
# registered on the wrong class.
class Shape; end
Shape.instance_eval do
  puts "setup"
  def sides = 4
end
p Shape.sides
