# A captured outer local must not defer a refusal implicitly.
# spinel: reject-subclass: block that captures outer locals
class CaptureBase; end
value = 3
klass = Class.new(CaptureBase) { define_method(:value) { value } }
p klass.new.value
