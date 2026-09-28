class Callback
  class << self
    attr_accessor :bind_to_object, :terminator
  end

  def options = { bind_to_object: self.class.bind_to_object, terminator: self.class.terminator }
  def toggle = (self.class.bind_to_object = !self.class.bind_to_object)
end

p Callback.new.options
Callback.bind_to_object = true
p Callback.new.options
Callback.new.toggle
p Callback.bind_to_object
