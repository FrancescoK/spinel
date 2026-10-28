# A singleton-class body reads class values through its enclosing lexical
# scopes, then Object, even when a method produced the class at run time.
def make = Struct.new(:value)
K = make
module Outer
  A = make
  class << self
    p A.new(3).value
    p K.new(4).value
  end
end
