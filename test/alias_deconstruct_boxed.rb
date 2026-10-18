# A #deconstruct given by `alias deconstruct child_nodes` answers an array
# pattern through the aliased method, on a boxed receiver and on a typed
# one, and an alias of an inherited child_nodes keeps the ancestor's.
class A
  def initialize(v) = @v = v
  def child_nodes = [@v, :a]
  alias deconstruct child_nodes
end

class Base
  def child_nodes = [:base]
end

class B < Base
  alias deconstruct child_nodes
end

class C < B
  def child_nodes = [:c]
end

xs = [A.new(1), B.new, C.new, A.new(2)]
p xs[ARGV.size].child_nodes
xs.each do |x|
  r = case x
      in [n, :a] then [:a, n]
      in [s] then [:one, s]
      end
  p r
end

r = case A.new(3)
    in [n, :a] then [:a, n]
    end
p r
r = case B.new
    in [s] then [:one, s]
    end
p r
r = case C.new
    in [s] then [:one, s]
    end
p r
