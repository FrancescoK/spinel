# The same through `self.new` and `allocate` in an inherited class method: a
# descendant the program reaches only by calling the method is built, and
# rendered, as itself.
class Shape
  def initialize(name = "shape")
    @name = name
  end

  def self.fresh = self.new
  def self.blank = allocate
  def to_s = "#{self.class}(#{@name})"
end

class Round < Shape
end

class Oval < Round
  def inspect = "oval:#{@name}"
end

class Flat < Round
end

def show(o) = puts [o, 1].inspect.gsub(/0x\h+/, "XX")

o = Oval.fresh
f = Flat.blank
puts o.class, f.class
puts o.to_s
show(o)
puts [o, f].map(&:class).inspect
