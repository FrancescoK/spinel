# `||=` and `&&=` on a receiver whose reader or writer method is defined on
# an ancestor class, not on the receiver's own class.
class MethodAttr
  attr_reader :block_params

  def initialize
    @block_params = nil
    @label = "start"
  end

  def block_params=(value)
    @block_params = value.strip
  end

  def label
    @label
  end

  def label=(value)
    @label = value.upcase
  end
end

class AnyMethod < MethodAttr
end

class Ghost < AnyMethod
  def label=(value)
    @label = "ghost " + value
  end
end

def fill(meth, block_params)
  meth.block_params ||= block_params if block_params
  meth
end

p fill(AnyMethod.new, " x, y ").block_params
p fill(AnyMethod.new, nil).block_params

m = AnyMethod.new
p(m.label &&= "next")
p(m.label ||= "unused")
p m.label

g = Ghost.new
p(g.label &&= "next")
p g.label

# A private writer on an ancestor still refuses an explicit receiver; self
# may call it.
class Hidden
  def initialize = @v = nil
  def v = @v
  def fill = (self.v ||= 3)
  private
  def v=(x)
    @v = x
  end
end

class HiddenKid < Hidden
end

[Hidden.new, HiddenKid.new].each do |o|
  begin
    o.v ||= 1
  rescue NoMethodError => e
    p e.class
  end
  p o.v
  o.fill
  p o.v
end
