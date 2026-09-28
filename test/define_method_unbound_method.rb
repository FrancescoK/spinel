# define_method with an UnboundMethod copies that method's current body
class P
  def x(n) = n * 10
  def y(a, b: 1) = a + b
  def z(n) = n + 1
  define_method(:j, instance_method(:x))
  define_method("k", self.instance_method(:y))
  private define_method(:pz, instance_method(:z))
  def x(n) = n * 100
  def z(n) = 0
  def via = pz(1)
end

o = P.new
p o.j(4), o.x(4), o.k(1), o.k(1, b: 5), o.via
begin; o.j; rescue ArgumentError => e; p e.message; end
begin; o.pz(1); rescue NoMethodError => e; p e.class; end
p P.public_method_defined?(:j), P.private_method_defined?(:pz)
