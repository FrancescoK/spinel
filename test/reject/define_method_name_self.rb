# spinel: reject-subclass: Module#define_method with a non-literal name
class DynamicName
  name = :value
  self.define_method(name) { 7 }
end
p DynamicName.new.value
