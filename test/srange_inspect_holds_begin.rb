# A String Range's inspect holds the begin's inspect while it inspects the
# end, which allocates (#8322); the range itself may be a by-value pair no
# one roots, as a lambda's answer is.
# spinel: gc-stress
f = lambda { |i| (String.new("a#{i}")..String.new("z#{i}")) }
p f.call(8)
r = (String.new("b1")...String.new("y1"))
p r
puts r.inspect
