# A bare `private` in a module_eval'd text ends with the eval: spliced into
# the body it would make the later `def bar` private. Not expanded.
module Defs
  def hidden(n) = module_eval("private; def #{n} = 1")
end
class Box
  extend Defs
  hidden :foo
  def bar = 2
end
p Box.new.bar
