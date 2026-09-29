# Class.new with a block: a constant-named one is a class definition, a static
# anonymous one a named class, and one built from a method's locals no longer
# leaks its defs into the enclosing class (Host#initialize stays Host's).
Err = Class.new(StandardError)
Pt = Class.new do
  def initialize(x) = @x = x
  def x = @x
end
p Pt.new(3).x
begin
  raise Err, "boom"
rescue Err => e
  p e.message
end
class Host
  def initialize(a) = @a = a
  def make(v)
    k = Class.new do
      define_method(:v) { v }
      def hi = "hi"
    end
    k.new.hi
  end
  def a = @a
end
p Host.new(7).a

# an anonymous class built in a module's method resolves its superclass and
# constants in that module
module Outer
  class Base
    def who = "Outer::Base"
  end
  K = 3
  def self.mk = Class.new(Base) { def hi = "#{who} #{K}" }
end
class Base
  def who = "::Base"
end
p Outer.mk.new.hi
