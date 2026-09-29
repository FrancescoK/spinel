module Integration
  def generate_message(name) = format(defaults[name], state: 1)
  private
  def defaults = { bad: "%<state>s bad" }
end
class Machine
  include Integration
  attr_accessor :state
  def generate_message(name) = "machine #{name}"
end
class Other
  attr_accessor :state
end
def write(object, attribute, value) = object.send("#{attribute}=", value)
[Machine.new, Other.new].each { |o| write(o, :state, 5); p o.state }
p Machine.new.generate_message(:bad)
