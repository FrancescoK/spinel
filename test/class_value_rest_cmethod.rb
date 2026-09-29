# A class method taking *rest (a DSL that is also its own getter, the
# FFI::Struct.layout shape) called on a Class held in a variable, an ivar, or
# a poly slot: the surplus arguments are packed into the splat, and a class
# value never enters an instance method of the same name.
class S
  def self.layout(*spec)
    return @layout if spec.empty?
    @layout = spec
  end
  def layout = self.class.layout
end
class A < S
  layout :a, :int
end
class B < S
  layout :b, :double, :c, :pointer
end
class Holder
  def initialize(klass)
    @k = klass
    @l = klass.layout
  end
  def l = @l
  def again = @k.layout
end
p Holder.new(A).l, Holder.new(B).again
p A.new.layout
vals = [A, B.new, 3]
p vals[0].layout, vals[1].layout
k = [A, B][1]
p k.layout
