class String
  def blank2? = strip.empty? unless method_defined?(:blank2?)
  def upcase = "hijacked" unless method_defined?(:upcase)
  unless method_defined?(:to_s)
    def to_s = "nope"
  end
end
p " ".blank2?
p "x".upcase
p "y".to_s

class Range
  def overlap2?(o) = !(self.end < o.begin || o.end < self.begin) unless method_defined?(:overlap2?)
end
p (1..3).overlap2?(2..5)

module Helpers
  def greet = "hi" unless method_defined?(:greet)
  def greet2 = "first"
  def greet2 = "second" unless method_defined?(:greet2)
  def shout = "HEY" unless self.method_defined?(:shout)
end
class User
  include Helpers
end
p User.new.greet
p User.new.greet2
p User.new.shout

class Base
  def id = 1
end
class Child < Base
  def id = 2 unless method_defined?(:id)
end
p Child.new.id
unless String.method_defined?(:squish2)
  class String
    def squish2 = split.join(" ")
  end
end
p "a  b".squish2

class Widget
  define_method(:size) { 3 }
  alias_method :count, :size
  alias tally size
  attr :label
  def size = 0 unless method_defined?(:size)
  def count = 0 unless method_defined?(:count)
  def tally = 0 unless method_defined?(:tally)
  def label = "none" unless method_defined?(:label)
end
w = Widget.new
p w.size
p w.count
p w.tally
p w.label
class Gadget
  def self.attribute(name); end
  attribute :caption
  attr_writer :width
  def caption = "fallback" unless method_defined?(:caption)
  def width = "width fallback" unless method_defined?(:width)
  unless method_defined?(:width=)
    def width=(v)
      raise "must not replace attr_writer"
    end
  end
end
g = Gadget.new
g.width = 3
p g.caption, g.width
