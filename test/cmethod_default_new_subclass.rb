# a class method whose parameter defaults to `new`, in a class with a
# subclass: the default is spelled at the call site, where the receiving
# class is the one the call names, not the method's own parameter
class P
  def initialize(n = 0) = @n = n
  def n = @n
  def self.make(x = new) = x
  def self.make2(a, x = new(a)) = x
end
class Q < P; end
p P.make.class, Q.make.class
p P.make2(3).n, Q.make2(4).class, Q.make2(5).n
p P.make(Q.new(7)).class
