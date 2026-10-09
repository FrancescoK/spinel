# A method of a module that is mixed in runs as a copy made for each class
# that includes the module, and no signature reaches the copies: --rbs seeds
# the module's own method, which is copied away. The annotation is reported
# and ignored whole, the same effect as the equivalent --rbs signature.
module Greeter
  #: (String) -> String
  def twice(n) = n * 2
end

class Pair
  include Greeter
end

p Pair.new.twice(21)
