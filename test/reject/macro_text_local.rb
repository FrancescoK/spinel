# A module_eval'd text sees the macro's locals, not the class body's: spliced
# it would read the body's `z`. Not expanded.
module Defs
  def mark(n) = module_eval("Y = defined?(z).inspect")
end
class Box
  extend Defs
  z = 1
  mark :foo
end
p Box::Y
