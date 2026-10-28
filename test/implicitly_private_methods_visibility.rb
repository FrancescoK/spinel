# initialize_copy, initialize_dup, initialize_clone and respond_to_missing?
# are private however they are defined, as CRuby makes them: a class's own
# definitions answer the reflection queries as private ones.
class K
  attr_reader :n
  def initialize(n) = @n = n
  def initialize_copy(o)
    super
    @n = o.n + 1
  end
  def initialize_dup(o) = super
  def initialize_clone(o, freeze: nil) = super
  def respond_to_missing?(n, p = false) = n == :ghost
end
p K.private_method_defined?(:initialize_copy), K.public_method_defined?(:initialize_copy)
p K.private_method_defined?(:initialize_dup), K.private_method_defined?(:initialize_clone)
p K.private_method_defined?(:respond_to_missing?)
k = K.new(1)
p k.respond_to?(:initialize_copy)
p K.private_instance_methods(false).sort
p K.public_instance_methods(false).sort
p k.dup.n, k.clone.n
