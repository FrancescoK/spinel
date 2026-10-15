# p of an object whose inspect unions a String with another branch type
# (returns a boxed sp_RbVal) routes through sp_poly_to_s, as puts does
# since #3266.
class Shown
  def initialize(flag) = @flag = flag
  def inspect = @flag ? "#<Shown>" : 7
end

class Holder
  def initialize(shown) = @shown = shown
  def show = (p @shown)
end

p Shown.new(true)
p Shown.new(false)
s = Shown.new(true)
p s
Holder.new(Shown.new(true)).show
Holder.new(Shown.new(false)).show
