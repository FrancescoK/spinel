module Consts
  def constant(name, v) = const_set(name, v)
end
class Calc
  extend Consts
  constant :SIZE, 32
  def self.size = SIZE
end
class Small
  extend Consts
  constant :SIZE, 4
  def self.size = SIZE
end
SIZE = 1
p Calc.size, Small.size, Calc::SIZE, Small::SIZE, SIZE
