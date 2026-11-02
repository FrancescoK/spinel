module Consts
  def constant(name, v) = const_set(name, v)
end
class Calc
  extend Consts
  constant :SIZE, 32
  def self.info = SIZE
end
p Calc.info, Calc::SIZE
