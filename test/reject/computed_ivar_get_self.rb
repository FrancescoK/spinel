# spinel: reject-subclass: non-literal name on a user-class instance
class IvarTarget
  def initialize = (@value = 7)
  def reflect(name) = instance_variable_get(name)
end
p IvarTarget.new.reflect(:@value)
