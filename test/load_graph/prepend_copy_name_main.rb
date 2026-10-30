# A prepend in the entry file over a class a required file defines, which also
# names a method exactly as the prepend's hidden copy (`__prep 0 foo`): the
# program's method stays its own.
require_relative "prepend_copy_name_lib"
module Loud
  def foo = "L+" + super
end
class Wrapped
  prepend Loud
end
w = Wrapped.new
p w.foo
p w.send(:"__prep 0 foo")
p Wrapped.instance_methods(false).sort
p w.respond_to?(:"__prep 0 foo")
