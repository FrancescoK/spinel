# spinel: reject-subclass: non-literal name on a user-class instance
class IvarTarget
  def initialize = (@value = 7)
end
name = :@value
p IvarTarget.new.instance_variable_get(name)
