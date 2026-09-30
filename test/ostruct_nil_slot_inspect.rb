# A typed OpenStruct slot left nil answers nil's #inspect ("nil") and
# nil's #to_s (""), not the rendering of an empty OpenStruct.
require "ostruct"
class Cfg
  attr_accessor :os
  def initialize(f) = (@os = OpenStruct.new(a: 2) if f)
end
n = Cfg.new(false).os
p n.inspect
p n.to_s
puts n.inspect
puts n.to_s
puts n.inspect.length, n.to_s.length
p n

# the answers are ordinary Strings: they can be compared, mutated and hashed
ins = n.inspect
ins << "x"
p ins
p n.inspect == "nil", n.inspect.hash == "nil".hash, "#{n.inspect}!", n.inspect.frozen?
p n.inspect.equal?(n.inspect)
emp = n.to_s
p emp.empty?, emp + "y"

# the same slot holding one
s = Cfg.new(true).os
p s.inspect
p s.to_s
puts s.inspect

# an Array miss
a = [OpenStruct.new(a: 1)]
p a[5].inspect, a[5].to_s
