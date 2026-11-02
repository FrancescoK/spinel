module Consts
  def constant(name, v) = const_set(name, v)
end
class Calc
  extend Consts
  EARLY = defined?(SIZE) ? SIZE : :none
  constant :SIZE, 32
  LATE = SIZE
end
p Calc::EARLY, Calc::LATE
