# spinel: reject-subclass: Module#define_method with a non-literal name
class Foo
  def self.prop(n)
    define_method(n) { n.to_s * 2 }
  end
end
Foo.prop :x
p Foo.new.x
