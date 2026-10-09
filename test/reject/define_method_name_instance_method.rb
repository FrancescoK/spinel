# spinel: reject-subclass: Module#define_method with a non-literal name
class Foo
  def build(names)
    names.each { |n| define_method(n) { 1 } }
  end
end
Foo.new.build([:a])
