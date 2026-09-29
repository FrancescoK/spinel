# const_get with a name known only at run time on a module constant is a
# lookup in a table of the module's constants (a class or module its bodies
# define, or a constant they assign); it typed nothing (#4843).
module Carts
  class A
    def initialize(x) = @x = x
    def x = @x
  end
  TYPES = { 0 => :A }.freeze
  def self.runtime(t, x) = Carts.const_get(TYPES.fetch(t)).new(x)
end
p Carts.runtime(0, 5).x
