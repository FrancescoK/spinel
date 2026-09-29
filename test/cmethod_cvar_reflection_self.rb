# class_variable_get/set/defined? bare or on self inside a class method
# reflect on that class's class variables
class B
  @@a = 1
  def self.get = class_variable_get(:@@a)
  def self.defined = class_variable_defined?(:@@a)
  def self.self_get = self.class_variable_get(:@@a)
  def self.set_new = class_variable_set(:@@z, class_variable_defined?(:@@z))
  def self.set_self = self.class_variable_set(:@@y, 5)
  class << self
    def bump = class_variable_set(:@@a, class_variable_get(:@@a) + 1)
  end
end

module M
  class N
    def self.set = class_variable_set(:@@n, "n")
    def self.get = class_variable_get(:@@n)
  end
end

p B.get
p B.defined
p B.self_get
p B.set_new
p B.set_new
p B.set_self
p B.bump
p B.class_variables.sort
p M::N.set
p M::N.get
