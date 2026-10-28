# A constant assigned a class value -- a method's result, a conditional --
# rather than a class definition or a builder holds a class known only at
# run time. Its reads dispatch on that class, as a variable's do: read by
# name they found no class and raised NameError.

module M
  def hi = "m"
end

def make = Struct.new(:a, :b) { include M }

K = make
p K.include?(M), K.ancestors.include?(M)
p K.new(1, 2).is_a?(M), K.new(1, 2).hi
p K.new(3, 4).b, K.new(5, 6).to_a

class Foo
  def initialize(x = 0) = @x = x
  def x = @x
end

class Bar
  def x = -1
end

def pick(b) = b ? Foo : Bar

F = pick(true)
p F.new(7).x, F.new.x, F.name

# read inside a method, after the load
def build = K.new(8, 9).a
p build

$flag = ARGV.empty?
C = $flag ? Bar : Foo
p C.new.x

module Outer
  N = $flag ? Foo : Bar
  def self.go = N.new(10).x
  class In
    def y = N.new(11).x
  end
end
p Outer.go, Outer::In.new.y
