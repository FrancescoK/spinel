class Knob
  class << self
    attr_accessor :level
    def set(v) = (self.level = v)
  end
end
p Knob.set(3)
x = Knob.set(4)
p x
p Knob.send(:level=, 5)
p Knob.level

class Switch
  class << self
    attr_accessor :flag
  end
  def toggle = (self.class.flag = !self.class.flag)
end
s = Switch.new
p s.toggle
p s.toggle
p Switch.flag

class Body
  class << self
    attr_accessor :items
  end
  self.items = [1, 2]
  p self.items
  p(self.items = [3])
end
p Body.items

class Store
  @value = 1
  class << self
    attr_accessor :value
  end
  def self.peek = @value
end
p Store.value
Store.value = "text"
p Store.value
p Store.peek
p [Store.value, Store.peek.size]
