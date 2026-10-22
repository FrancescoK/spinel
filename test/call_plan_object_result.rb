# Inherited Object results are coerced to the consumer's representation.
class Object
  def instance_variable_get(name) = :object
end
class Plain; end
p StandardError.new("message").instance_variable_get(:@key)
p Plain.new.instance_variable_get(:@key)
