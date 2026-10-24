# `String.include(M)` inside a method runs only when the method does, so it
# is not rewritten into a reopening: it is refused at compile time instead of
# raising NoMethodError at run time.
module Shout
  def shout = "!"
end
def setup = String.include(Shout)
setup
p "a".shout
