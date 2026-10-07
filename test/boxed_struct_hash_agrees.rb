# A Struct read out of a mixed Array answers #hash with the value a typed
# one does, so equal structs hash alike however they were reached; Hash
# lookups and uniq across the two still find each other.
P = Struct.new(:x, :y)
Q = Struct.new(:name)
b = [P.new(1, 2), "z"][0]
p b.hash == P.new(1, 2).hash
p b.hash == [P.new(1, 2), 1][0].hash
p b.hash == P.new(2, 1).hash
p [Q.new("a"), 0][0].hash == Q.new("a").hash
h = {P.new(1, 2) => :a}
p h[b]
p({b => 1}.key?(P.new(1, 2)))
p [b, P.new(1, 2), P.new(3, 4)].uniq.size
p [P.new(1, 2), "z"].map(&:hash).first == P.new(1, 2).hash
