# A class's bodies in two files run in load order: its includes go in front
# in that order, an alias takes the method in effect where it stands, and a
# module an earlier include in a required file reaches is no new method.
module B
  def hi = "B"
end
module M1
  def m = "m1"
end
module M2
  include M1
end
module M3
  include M2
end
class Greeter
end
class Box
end
require_relative "mixin_order_lib"
class Greeter
  alias_method :hello, :hi
  include B
end
g = Greeter.new
puts g.hello
puts g.hi
p Greeter.ancestors.take(3)
b = Box.new
puts b.m
class Box
  include M3
end
puts b.m
