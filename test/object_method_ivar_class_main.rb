# spinel: gc-minor
# Class values and main read their ordinary storage through boxed Object self.
class Object
  def shared_value = @value
  def reflective_value = instance_variable_get(:@value)
end
class ClassValue
  @value = :class_value
  def self.own = @value
  def initialize = (@value = 7)
end
class EmptyClassValue; end
p ClassValue.shared_value, ClassValue.reflective_value, ClassValue.own
p ClassValue.new.shared_value, EmptyClassValue.shared_value
@value = 5
p shared_value, reflective_value, @value
@value = nil
p shared_value, reflective_value, @value
