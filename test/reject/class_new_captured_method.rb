# Captures in a class factory are refused even before a method is called.
# spinel: reject-subclass: block that captures outer locals
class CaptureMethodBase; end
def captured_class(value)
  Class.new(CaptureMethodBase) { define_method(:value) { value } }
end
p captured_class(3).new.value
