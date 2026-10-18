# `self.x = v` on a receiver that may be a class or an instance (an
# instance_exec'd block, as activesupport's on_load hooks run) answers v;
# where the call's value is boxed -- the block's own value -- v is boxed
# too, whatever its kind (a Symbol here, as in actionpack's
# `self.action_on_open_redirect = :log`).
class Base
  def self.mode=(v); @mode = v; end
  def self.mode = @mode
  def mode=(v); @m = v; end
  def m = @m
end

class Other
  def self.mode=(v); @mode = v; end
  def self.mode = @mode
end

def hook(target, &blk) = target.instance_exec(&blk)

p hook(Base) { self.mode = :log }, Base.mode
p hook(Other) { self.mode = :raise }, Other.mode
b = Base.new
p hook(b) { self.mode = :x }, b.m
p hook(Base) { self.mode = 3 }, Base.mode
p hook(Other) { self.mode = "s" }, Other.mode
