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

def arity_of(object, sym)
  object.method(sym).arity
end

p [Machine.new, Other.new].map { |o| arity_of(o, :state=) }
p [Machine.new, Other.new].map { |o| arity_of(o, :state) }
p [Machine.new, Other.new].map { |o| o.method(:state=).arity }
