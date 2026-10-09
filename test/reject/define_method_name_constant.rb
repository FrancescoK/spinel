# spinel: reject-subclass: Module#define_method with a non-literal name
class DynamicName
  NAME = "value"
  define_method(NAME) { 7 }
end
p DynamicName.new.value
