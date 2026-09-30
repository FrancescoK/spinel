# A macro reading an ivar of the class is not evaluated: the state a class
# body leaves in it is not followed, so the call stays as written (a run-time
# public_send, refused), not expanded with a nil in place of the ivar.
module Consts
  def constant(c)
    const_set(c, public_send(["calc", @kind, c.to_s.downcase].compact.join("_")))
  end
end
class Calc
  extend Consts
  def self.calc_size = 1
  def self.calc_box_size = 2
  @kind = :box
  constant :SIZE
end
p Calc::SIZE
