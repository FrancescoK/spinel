# Inherited Object results are coerced to the consumer's representation.
class Object
  def instance_variable_get(name) = :object
end
class Plain; end
p StandardError.new("message").instance_variable_get(:@key)
p Plain.new.instance_variable_get(:@key)

# A value-less inherited result leaves nil in the consumer's slot.
class Object
  def instance_variables
    puts "listing #{self.class}"
  end
  def singleton_methods
    raise ArgumentError, "no singleton methods on #{self.class}"
  end
end
p StandardError.new("message").instance_variables
v = StandardError.new("message").instance_variables
p v
begin
  p StandardError.new("message").singleton_methods
rescue ArgumentError => e
  p e.message
end
