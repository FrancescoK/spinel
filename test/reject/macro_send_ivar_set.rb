# instance_variable_set reached through a send with a literal name writes the
# state: the macro reading it is left as written (refused).
module Consts
  def kind(k = nil)
    return @kind if k.nil?
    @kind = k
  end
  def constant(c)
    const_set(c, public_send(["calc", kind, c.to_s.downcase].join("_")))
  end
end
class Calc
  extend Consts
  def self.calc_a_size = 1
  def self.calc_b_size = 2
  kind :a
  send(:instance_variable_set, :@kind, :b)
  constant :SIZE
end
p Calc::SIZE
