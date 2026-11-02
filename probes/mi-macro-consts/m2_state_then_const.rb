module Consts
  def kind(k = nil)
    return @kind if k.nil?
    @kind = k
  end
  def constant(c) = const_set(c, public_send("calc_#{kind}_#{c.to_s.downcase}"))
end
class Calc
  extend Consts
  def self.calc_box_size = 32
  kind :box
  constant :SIZE
end
p Calc::SIZE, Calc.kind
