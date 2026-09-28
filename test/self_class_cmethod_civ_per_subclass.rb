# `self.class.m` from an instance method inherited by subclasses: `m` is an
# inherited class method reading a class-level @ivar, and each subclass holds
# its own. The call must reach the subclass's storage, not the base class's --
# the FFI::Struct shape, where `#[]` reads `self.class.layout`.
class Base
  def self.layout(*spec)
    @fields = {}
    off = 0
    spec.each_slice(2) { |n, t| @fields[n] = [off, t]; off += 8 }
  end
  def self.fields = @fields
  def look(name)
    off, t = self.class.fields[name]
    [off, t]
  end
  def get = self.class.fields[:x]
end
class A < Base
  layout :x, :int, :y, :pointer
end
class B < Base
  layout :y, :double, :x, :float
end
p A.new.look(:y)
p B.new.look(:x)
p A.new.get, B.new.get
