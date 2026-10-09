# A lambda held by an ivar that an attr_reader exposes is read, so its capture is refused.
# spinel: reject-subclass: block that captures outer locals
class FactoryHolder
  attr_reader :factory
  def initialize(value)
    @factory = -> { Class.new { define_method(:value) { value } } }
  end
end
p FactoryHolder.new(3).factory.call.new.value
