# Poly plans retain builtin defaults and class-value arms with the same
# argument representation, accessor precedence and visibility as emission.

class Other
  def cover?(x) = x == 3
end
[(1..5), Other.new].each { |x| p x.cover?(3); p x.cover?(9) }

class Day
  def strftime(x) = "day:#{x}"
end
[Time.at(0).utc, Day.new].each { |x| p x.strftime("%Y") }

class Base
  def self.label = "base"
end
class Child < Base
  class << self
    attr_accessor :label
  end
end
Child.label = "child"
[Base, Child, 1].each { |k| p k.label if k.is_a?(Class) }

class C
  def self.foo = 1
  private_class_method :foo
end
class D
  def self.foo = 2
end
[C, D].each { |k| begin; p k.foo; rescue NoMethodError; puts "private"; end }

class First
  def self.consume(s) = s << "A"
end
class Second
  def consume(s) = s << "B"
end
[First, Second.new].each { |k| s = +"x"; p k.consume(s); p s }
