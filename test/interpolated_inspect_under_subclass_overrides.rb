# `#{inspect}` in a base class whose subclasses override inspect dispatches over
# those classes, and one answering no String makes the call boxed: the default
# renderer the base class takes answers its text as a boxed String then.
class Node
  def accept(_visitor)
    raise NoMethodError, "undefined method `accept' for #{inspect}"
  end
end
class Leaf < Node
  def initialize(v); @v = v; end
  def inspect = @v
end
class Twig < Node
  def inspect = "twig"
end
begin
  Leaf.new("leaf!").accept(nil)
rescue NoMethodError => e
  puts e.message
end
begin
  Twig.new.accept(nil)
rescue NoMethodError => e
  puts e.message
end
begin
  Leaf.new(42).accept(nil)
rescue NoMethodError => e
  puts e.message
end
