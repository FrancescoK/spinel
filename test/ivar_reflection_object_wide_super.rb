# A reflection defined on Object that calls super reaches Kernel's: the
# object's own fields, for an instance of a program class and, through a
# receiver that can be of any class, for a builtin value.
class Object
  def instance_variable_get(x) = (super(x) || :none)
end
class Plain
  def initialize = (@p = +"pl")
end

s = Plain.new.instance_variable_get(:@p)
s << "!"
p s, Plain.new.instance_variable_get(:@q)
xs = [Plain.new, 3, nil]
xs.each { |x| p x.instance_variable_get(:@p) }
