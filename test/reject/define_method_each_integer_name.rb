# spinel: reject-subclass: Module#define_method with a non-literal name
class K
  [1].each { |n| define_method(n) { 1 } }
end
p K.instance_methods(false)
