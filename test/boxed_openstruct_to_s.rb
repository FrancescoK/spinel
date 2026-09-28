# to_s, puts and interpolation of an OpenStruct read out of a container
# render it as its inspect does, as a typed OpenStruct's to_s does.
require "ostruct"
o = OpenStruct.new(a: 1, b: "x")
x = [o, 0][0]
p x.to_s
puts x
puts "v=#{x}"
p [OpenStruct.new, 0][0].to_s
puts [x, 2]
o.c = [3]
puts "#{x}!"

# other routes to the same rendering
def two = 2
puts x, two
$stdout.puts x
puts [x, OpenStruct.new(z: 1)].join(",")
puts format("%s|%s", x, o)

# a temporary held by nothing else
def mk(i) = i.even? ? OpenStruct.new(a: "s#{i}", b: [i, "t#{i}"]) : i
n = 0
300.times { |i| n += mk(i).to_s.length }
p n
