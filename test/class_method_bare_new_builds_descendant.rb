# A class method a descendant inherits runs with self the descendant, so its
# bare `new` builds the descendant: a class two levels down that the program
# only reaches by calling the inherited method, with no `new` of its own, has
# an instance, a constructor and an arm in the switches that render it, whether
# the method is inherited directly or through a `super` in a class between.
class Shape
  def initialize(name = "shape")
    @name = name
  end

  def self.make(name) = new(name)
  def to_s = "#{self.class}(#{@name})"
end

class Round < Shape
end

class Oval < Round
  def inspect = "oval:#{@name}"
end

class Square < Shape
end

class Ring < Shape
  def self.make(name) = super
end

class Band < Ring
  def inspect = "band:#{@name}"
end

class Strap < Band
end

def show(o) = puts [o, 1].inspect.gsub(/0x\h+/, "XX")

z = Shape.make("z")
o = Oval.make("a")
s = Square.make("b")
t = Strap.make("c")
u = Band.make("d")
puts z.class, o.class, s.class, t.class, u.class
puts o.to_s, s.to_s, t.to_s
show(o)
show(s)
show(t)
show(u)
puts [o, s, t, u].map(&:class).inspect
