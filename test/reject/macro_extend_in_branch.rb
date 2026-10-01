# An extend under a condition is not one the class is known to make: the
# call after it is not expanded (its run-time public_send refused), not
# expanded as though the module were extended.
module Consts
  def constant(c) = const_set(c, public_send("calc_#{c.to_s.downcase}"))
end
class Calc
  def self.calc_size = 1
  extend Consts if ARGV.empty?
  constant :SIZE
end
p Calc::SIZE
