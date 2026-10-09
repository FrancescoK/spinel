# spinel: reject-subclass: Module#define_method with a non-literal name
class Foo
  def self.prop(n)
    define_method(n) { n.to_s * 2 }
  end
  prop :x
end
p Foo.new.x
