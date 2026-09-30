# A macro changing a local array in place is not followed: what `parts << x`
# leaves in it is the run time's, so the macro is not expanded (its run-time
# public_send refused), not expanded with the array before the change.
module Consts
  def constant(c)
    parts = ["calc", "box"]
    parts << "x"
    const_set(c, public_send((parts + [c.to_s.downcase]).join("_")))
  end
end
class Calc
  extend Consts
  def self.calc_box_size = 1
  def self.calc_box_x_size = 2
  constant :SIZE
end
p Calc::SIZE
