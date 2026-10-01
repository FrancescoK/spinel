# A const_added hook sees every constant CRuby's const_set defines: an
# expansion would define it without running the hook, so nothing is expanded.
module Sizes
  def constant(c) = const_set(c, public_send("calc_#{c.to_s.downcase}"))
end
class Calc
  extend Sizes
  def self.const_added(name) = puts("added #{name}")
  def self.calc_size = 32
  constant :SIZE
end
p Calc::SIZE
