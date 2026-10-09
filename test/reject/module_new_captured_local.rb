# A Module.new held in a local is refused for the same capture.
# spinel: reject-subclass: block that captures outer locals
value = 5
mod = Module.new do
  define_method(:value) { value }
end
klass = Class.new { include mod }
p klass.new.value
