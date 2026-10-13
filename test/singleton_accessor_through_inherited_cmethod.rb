# A `class << self` accessor is per class: its @ivar is the class's own, as
# any class-level @ivar is. A class method a subclass inherits that reads or
# writes it through self (`self.x = 3`, `x`) reaches the CALLING class's
# slot. The inherited method was not specialized for the subclass, so it
# kept the defining class's slot: C.setup wrote B's, and C.x stayed nil.
class B
  class << self
    attr_accessor :x
  end

  def self.setup(v)
    self.x = v
    x
  end
end

class C < B; end

p B.setup(1)
p C.setup(2)
p B.x, C.x
C.x = 5
p B.x, C.x
