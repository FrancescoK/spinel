# As mixin_include.rb, with the module in a second file: the warning names
# the file the annotation is written in.
require_relative "mixin_req_part"

class Pair
  include Greeter
end

p Pair.new.twice(21)
