# A block that answers `(+v) << x` over an Array's element answers the
# element itself when it is not frozen, a new String when it is: map's
# answer holds those, and the Array keeps its own.
a = ["x", "y"]
r = a.map { |v| (+v) << "!" }
p r, a
b = ["x", +"y"]
r2 = b.map { |v| (+v) << "!" }
p r2, b, r2[0].equal?(b[0]), r2[1].equal?(b[1])
h = {k: "v"}
h.each { |k, v| p((+v) << "?") }
p h
r3 = b.map { |v| (+v).concat("?") << "." }
p r3, b, r3[1].equal?(b[1])
