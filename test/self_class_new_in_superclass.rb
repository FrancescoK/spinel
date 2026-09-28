# `self.class.new` in an instance method of a class that has subclasses
# builds whichever class the receiver has, as a class-valued `new` does.
class Base
  def dup_with(x) = self.class.new(x)
end
class Q < Base
  attr_reader :s
  def initialize(s) = @s = s
end
p Q.new(3).dup_with(4).s

class Shape
  attr_reader :v
  def initialize(v) = @v = v
  def again(x) = self.class.new(x)
  def spread(*a) = self.class.new(*a)
end
class Wide < Shape
  def initialize(v, w = 2) = (@v = v + w)
end
class Scaled < Shape
  def initialize(v, k: 10) = (@v = v * k)
end
p Shape.new(1).again(5).v
p Wide.new(1).again(5).v
p Scaled.new(1).again(5).v
p Wide.new(1).spread(5, 7).v
p Wide.new(1).again(5).class

class Blank
  attr_reader :v
  def initialize = @v = 0
  def fresh = self.class.new
end
class Filled < Blank
  def initialize = @v = 1
end
p Blank.new.fresh.v
p Filled.new.fresh.v
p Filled.new.fresh.class

class Leaf
  attr_reader :v
  def initialize = @v = :leaf
  def fresh = self.class.new
end
p Leaf.new.fresh.v

module Remake
  def remake(x) = self.class.new(x)
end
class One
  include Remake
  attr_reader :v
  def initialize(v) = @v = v
end
class Two
  include Remake
  attr_reader :v
  def initialize(v) = @v = [v]
end
p One.new(1).remake(2).v
p Two.new(1).remake(2).v
