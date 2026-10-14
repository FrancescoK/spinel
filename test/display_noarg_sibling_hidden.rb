# the no-argument siblings Spinel gives an inspect / to_s whose parameters
# are all optional are no methods of the class to reflection

class N
  def initialize(x) = @x = x
  def inspect(indent = 0) = "N(#{@x},#{indent})"
  def to_s(sep = ":") = "n#{sep}"
end
n = N.new(1)
p n
p N.instance_methods(false).sort
p N.public_instance_methods(false).sort
p N.private_instance_methods(false).sort
p n.respond_to?(:__noarg_inspect)
p N.method_defined?(:__noarg_to_s)
p n.public_methods(false).sort
p n.methods.include?(:__noarg_inspect)
p n.respond_to?(:__noarg_to_s, true)

# a method the program itself names like a sibling is its own, beside a
# class that has the siblings
class Own
  def __noarg_inspect = "own"
end
p Own.instance_methods(false)
p Own.new.respond_to?(:__noarg_inspect)
p Own.new.__noarg_inspect
