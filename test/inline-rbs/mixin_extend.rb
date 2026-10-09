# As mixin_include.rb, mixed in with `extend`: the copy is a class method of
# the class that extends the module.
module Greeter
  #: (String) -> String
  def twice(n) = n * 2
end

class Pair
  extend Greeter
end

p Pair.twice(21)
