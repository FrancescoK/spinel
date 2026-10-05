# The same for a Struct.new superclass, reached through a receiver the
# program does not name statically.
class Point < Struct.new(:x, :y)
end

def chain(k) = k.ancestors
p chain(Point).first(2)
