# A module's instance method named `inherited` that no class object has (the
# module is only included into a class) is no hook of any class header: the
# header of Sub runs no program code, so the call in `show` on a Sub made
# ahead of its override of `v` is a direct call, not an entry that chooses
# between versions at run time. Any class may have objects from `make(Base)`.
def make(k) = k.new
class Base
  def v = "base"
  def show = v
end
x = make(Base)
puts x.show
module Hooks
  def inherited(k) = k
end
class Other
  include Hooks
end
class Sub < Base
  def v = "sub"
end
p Sub.new.show
p x.show
