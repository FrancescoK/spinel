# The call is in a block whose self instance_eval rebinds to the class, so it
# reaches the class method, and the class method's provable NoMethodError is
# reported.
class Store
  def []=(k, v); end
  def label = "store"
  def self.label
    self[:v] = 1
    "class"
  end
  def show = self.class.instance_eval { label }
end

p Store.new.show
