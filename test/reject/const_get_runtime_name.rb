# const_get with a name known only at run time on a class held in a variable
# is refused where it is written: which module's table to read is not known
# at compile time either (#4843).
module Carts
  class A
    def initialize(x) = @x = x
    def x = @x
  end
  TYPES = { 0 => :A }.freeze
end
mod = [Carts, Kernel].first
p mod.const_get(Carts::TYPES.fetch(0)).new(5).x
