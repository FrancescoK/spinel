# A computed instance_variable_get name reads by name over the class's ivars (#8219); this program was refused before.
class IvarTarget
  def initialize = (@value = 7)
  def reflect(name) = instance_variable_get(name)
end
p IvarTarget.new.reflect(:@value)
