# An alias of an inherited method names the ancestor's body in effect where
# the alias appears: a subclass that overrides the method does not change
# what the alias calls, through the forwarder a subclass body's alias
# becomes and through the alias of a reopened subclass alike.
class P
  def m(x = 0, &b) = b ? b.call(x + 1) : x + 1
  def run = o(10)
end
class D < P
  alias o m
  alias_method :o2, :m
end
class E < D
  def m(x = 0) = -1
end
p D.instance_methods(false).sort
p E.new.o, E.new.o(2), E.new.o2(3) { |v| v * 10 }, E.new.run, E.new.m
p E.new.respond_to?(:o), E.new.method(:o).owner

class Q
  def name = "Q"
end
class R < Q; end
class R
  alias old_name name
end
class S < R
  def name = "S"
end
p S.new.old_name, S.new.name

# a `class << self` alias took the inherited class method: redefining the
# instance method of the name later does not touch it
class SP
  def m = "SP#m"
  def self.m = "SP.m"
end
class SD < SP
  class << self
    alias o m
  end
end
class SP
  def m = "SP#m2"
end
p SD.o, SD.new.m
