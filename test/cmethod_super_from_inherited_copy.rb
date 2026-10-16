# a class method that calls super, run on a subclass that inherits it: the
# method is copied into the subclass (its class-level @ivars are the
# subclass's), and its super runs the parent's method with self still the
# subclass, whose @ivars it writes too
class Base
  def self.attach_to(ns)
    @ns = ns
  end
  def self.ns = @ns
end

class Log < Base
  def self.attach_to(ns)
    @levels = super
  end
  def self.levels = @levels
end

class Sub < Log
end

class Other < Log
end

Sub.attach_to(:sub)
Other.attach_to(:other)
p Sub.ns, Sub.levels
p Other.ns, Other.levels
p Log.ns, Base.ns

# the method's own body names no class-level @ivar, its super does
class Plain < Base
  def self.attach_to(ns) = super
end
class Leaf < Plain
end
Leaf.attach_to(:leaf)
p Leaf.ns, Plain.ns
