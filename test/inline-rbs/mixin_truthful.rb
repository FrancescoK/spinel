# A true signature on a mixed-in module's method is reported too: the rule is
# about where the method runs, not whether the annotation is right.
module Greeter
  #: (String) -> String
  def twice(s) = s * 2
end

class Pair
  include Greeter
end

class Trio
  include Greeter
end

p Pair.new.twice("a")
p Trio.new.twice("b")
