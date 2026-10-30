# Reflection lists the public name of a renamed prepend body.
module L
  def m = "L " + super
end
class K
  def m = "k"
  def n = 1
end
k = K.new
def q(k) = [K.instance_methods(false).sort, K.public_instance_methods(false).sort, k.respond_to?(:m), K.method_defined?(:m), K.instance_method(:m).name]
p q(k)
class K; prepend L; end
p q(k), k.m
