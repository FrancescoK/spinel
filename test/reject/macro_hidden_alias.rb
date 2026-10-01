# A class method of the macro's name, made by an alias in `class << self`,
# answers the call: the macro is not expanded (its run-time public_send
# refused), whichever order the class extends and aliases in.
module Consts
  def constant(c) = const_set(c, public_send("calc_#{c.to_s.downcase}"))
end
class Calc
  extend Consts
  def self.calc_size = 1
  def self.other(c) = const_set(c, 2)
  class << self
    alias_method :constant, :other
  end
  constant :SIZE
end
p Calc::SIZE
