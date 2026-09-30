# puts of a Hash prints its inspect, and puts of an OpenStruct its to_s (the
# same rendering); a nil OpenStruct slot is `puts nil`, an empty line.
require "ostruct"
h = {a: 1}
puts h
puts({b: 2})
puts({"a" => 1}, {1 => 2})
puts({})
puts({"a" => "b"}, {1 => "x"}, {1 => 2, "k" => :v})
puts a: 1
puts 1, b: 2
g = {"x" => [1, "y"], "n" => nil}
puts g
def mk(i) = {k: "v#{i}", n: [i]}
puts mk(3)
e = Hash.new(0)
e[:z] += 1
puts e
q = nil
q = {a: 1} if ARGV.size > 5
puts q
t = OpenStruct.new(a: 1, b: "x")
puts t
class C
  attr_reader :os
  def initialize(f) = (@os = OpenStruct.new(a: 2) if f)
end
puts C.new(false).os
puts C.new(true).os
puts OpenStruct.new.to_h
puts t.to_h
x = [h, 1][0]
puts x
puts h, 5, "s"

# a Hash that a call returns and nothing else holds
def mkh(i) = {k: "v#{i}", n: [i, "w" * (i % 7)], s: "x#{i}"}
30.times { |i| puts mkh(i) }
