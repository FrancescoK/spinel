# Methods of modules that are included (not extended by a class body) and
# that send by name: nothing calls them with arguments they take, but super
# and pattern matching reach them, so they stay. (The word extend above lets
# the class-body macro pass look at the program.)
module Greet
  def greet(a, b) = public_send(:fmt, a, b)
end
class A
  include Greet
  def fmt(a, b) = "#{a}-#{b}"
  def greet(a) = super(a, 1)
end
p A.new.greet(2)

module Deco
  def deconstruct_keys(keys) = { x: public_send(:val) }
  def deconstruct = [send(:val), 2]
end
class Pt
  include Deco
  def val = 42
end
case Pt.new
in { x: } then p x
end
case Pt.new
in [a, b] then p a + b
end
