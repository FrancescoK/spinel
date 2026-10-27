# `new` on a block's parameter over a literal Array of classes builds only
# those classes: `[Box].map { |k| k.new("w") }` once typed every Struct's
# first member by its String argument, and a Data class's `[]` beside it
# then took its Integer arguments for the wrong type and raised
# NoMethodError.
Point = Data.define(:x, :y)
Pair = Struct.new(:a, :b)

class Box
  def initialize(v) = @v = v
  attr_reader :v
end

def get2(r, a, b) = r[a, b]

p [Box].map { |k| k.new("w").v }
[Box].each { |k| p k.new("x").v }
p [[1, 2, 3], Point, Pair].map { |r| get2(r, 1, 2) }
