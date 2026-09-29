class A
  attr_reader :start
  def initialize = @start = 1
  def twice = start * 2
end
class B < A
  def start = 50
end
class C < B
end
class D < A
  def start = super + 5
end
p A.new.twice, B.new.twice, C.new.twice, D.new.twice

class Named
  attr_reader :label
  def initialize = @label = "n"
  def show = "<#{label}>"
end
class Loud < Named
  def label = :loud
end
p Named.new.show, Loud.new.show

module HasSize
  attr_reader :size
  def describe = "size #{size}"
end
class Box
  include HasSize
  def initialize = @size = 3
end
class BigBox < Box
  def size = 30
end
p Box.new.describe, BigBox.new.describe

module Tweak
  def start = 7
end
class E < A
  include Tweak
end
p E.new.twice

class P
  attr_reader :w
  def initialize(w) = @w = w
  def area = w * w
end
p P.new(4).area
