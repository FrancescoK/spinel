# A call before the class extends the macro's module does not reach it: the
# call is not expanded (it stays a run-time NoMethodError), not silently made
# to work.
module Consts
  def constant(c) = const_set(c, public_send("calc_#{c.to_s.downcase}"))
end
class Calc
  def self.calc_size = 1
  constant :SIZE
  extend Consts
end
p Calc::SIZE
