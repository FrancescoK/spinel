# define_method with an UnboundMethod copies that method's current body,
# also when the UnboundMethod is fetched through send(:instance_method, ...)
# (that form was left undefined).
class P
  def x(n) = n * 10
  def y(a, b: 1) = a + b
  def z(n) = n + 1
  define_method(:j, instance_method(:x))
  define_method("k", self.send(:instance_method, :y))
  private define_method(:pz, instance_method(:z))
  def x(n) = n * 100
  def z(n) = 0
  def via = pz(1)
end

o = P.new
p o.send(:j, 4), o.send(:x, 4), o.send(:k, 1), o.send(:k, 1, b: 5), o.via
begin; o.j; rescue ArgumentError => e; p e.message; end
begin; o.send(:pz, 1); rescue NoMethodError => e; p e.class; end
p P.send(:public_method_defined?, :j), P.send(:private_method_defined?, :pz)
