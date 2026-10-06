# A computed class is checked for nil objects and for builtin receivers.
def boxed_class(v, unused = nil) = v
boxed_class(3)
class Animal; end
class Dog < Animal; end
pet = Animal.new
pet = nil if ARGV.empty?
p pet.instance_of?(boxed_class(Animal))
p pet.is_a?(boxed_class(Animal))
p pet.kind_of?(boxed_class(Animal))
p pet.instance_of?(boxed_class(NilClass))
p pet.is_a?(boxed_class(Object))
begin
  p pet.is_a?(boxed_class(3))
rescue TypeError => e
  puts e.message
end
pet = Dog.new
p pet.instance_of?(boxed_class(Animal))
p pet.instance_of?(boxed_class(Dog))
p pet.kind_of?(boxed_class(Animal))
p /a/.is_a?(boxed_class(Regexp))
p /a/.instance_of?(boxed_class(Regexp))
p /a/.is_a?(boxed_class(Numeric))
p (1r/3).is_a?(boxed_class(Numeric))
p (1r/3).instance_of?(boxed_class(Rational))
p (1r/3).is_a?(boxed_class(Comparable))
p Complex(1, 2).is_a?(boxed_class(Numeric))
p Complex(1, 2).instance_of?(boxed_class(Complex))
p Complex(1, 2).is_a?(boxed_class(Comparable))
p Time.now.is_a?(boxed_class(Comparable))
p Time.now.instance_of?(boxed_class(Time))
p Time.now.instance_of?(boxed_class(Object))

def allocated_class(v)
  puts "class evaluated"
  garbage = Array.new(20) { +"garbage" }
  v
end
allocated_class(3)
pet = nil if ARGV.empty?
p pet.instance_of?(allocated_class(Animal))
p pet.is_a?(allocated_class(NilClass))
pet = Dog.new
p pet.instance_of?(allocated_class(Dog))
p /a/.is_a?(allocated_class(Regexp))
p Complex(1, 2).instance_of?(allocated_class(Complex))
