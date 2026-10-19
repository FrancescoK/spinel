# A program's own instance_variable_get, _set, instance_variable_defined?
# and instance_variables reach Object's by super: the reflection of the object's own fields, which a read answers as
# the ivar's String itself and a write stores.
class Logged
  def initialize
    @n = +"lg"
    @log = []
  end
  def instance_variable_get(x)
    @log << x
    super
  end
  def instance_variable_set(k, v) = super(k, v * 2)
  def instance_variable_defined?(k) = super(k) && k != :@log
  def instance_variables = super + [:extra]
  def remove_instance_variable(k)
    @log << :removed
    :ours
  end
  def log = @log
end
class Plain
  def initialize = (@n = +"pl")
end

o = Logged.new
v = o.instance_variable_get(:@n)
p v
v << "!"
p o.instance_variable_get(:@n), o.log
p o.instance_variable_set(:@n, 5), o.instance_variable_get(:@n)
p o.instance_variable_defined?(:@n), o.instance_variable_defined?(:@log), o.instance_variable_defined?(:@zz)
p o.instance_variables
p o.remove_instance_variable(:@n), o.instance_variable_defined?(:@n), o.log

[Logged.new, Plain.new].each { |x| p x.instance_variable_get(:@n) }
w = [Logged.new, Plain.new].map { |x| x.instance_variable_get(:@n) }
w[0] << "?"
w[1] << "?"
p w
