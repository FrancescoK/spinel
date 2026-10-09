# A lambda held by a constant that is called keeps its captured class refused.
# spinel: reject-subclass: block that captures outer locals
value = 3
FACTORY = -> { Class.new { define_method(:value) { value } } }
p FACTORY.call.new.value
