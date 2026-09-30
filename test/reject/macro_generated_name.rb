# A macro that defines a class method named like another macro: a later call
# of that name reaches the generated method, not the macro, so it is not
# expanded (its run-time public_send refused).
module Gen
  def gen(n) = module_eval("def self.#{n}(x) = 1")
end
module Consts
  def constant(c) = const_set(c, public_send("calc_#{c.to_s.downcase}"))
end
class Calc
  extend Gen
  extend Consts
  def self.calc_size = 2
  gen :constant
  constant :SIZE
end
p Calc.const_defined?(:SIZE)
