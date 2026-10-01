# A module_eval template that assigns the ivar at its top level writes it now,
# where the compiler does not follow: a later macro reading it is left as
# written (a run-time public_send, refused).
module Setters
  def set_box = module_eval("@kind = :box")
end
module Consts
  def constant(c)
    const_set(c, public_send(["calc", @kind, c.to_s.downcase].compact.join("_")))
  end
end
class Calc
  extend Setters
  extend Consts
  def self.calc_size = 1
  def self.calc_box_size = 2
  set_box
  constant :SIZE
end
p Calc::SIZE
