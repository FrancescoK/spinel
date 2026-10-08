# StringIO is a class the stringio package binds to C: a subclass of it has
# none of its methods (#7075).
# spinel: reject-subclass: class Buffer < StringIO: subclassing StringIO
require "stringio"

class Buffer < StringIO
end

b = Buffer.new
b.write("ab")
p b.string
