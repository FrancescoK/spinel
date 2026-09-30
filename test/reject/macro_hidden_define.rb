# A class method of the macro's name, made by define_singleton_method with a
# literal name, answers the call: the macro is not expanded (its run-time
# public_send refused).
module Consts
  def constant(c) = const_set(c, public_send("calc_#{c.to_s.downcase}"))
end
class Calc
  extend Consts
  def self.calc_size = 1
  define_singleton_method(:constant) { |c| const_set(c, 2) }
  constant :SIZE
end
p Calc::SIZE
