# A compact path under a Struct constant comes before a `class` body that
# reopens the Struct. In CRuby both Point::Formatter bodies are one class.
# Spinel places the first one under no parent and the second one under
# Point, so the compiler refuses the program.
# spinel: reject-compact-path: a constant that holds a Struct or Data class, is not supported here
Point = Struct.new(:x)

class Point::Formatter
  def left = "("
end

class Point
  def label = "point #{x}"
end

class Point::Formatter
  def right = ")"
end

f = Point::Formatter.new
puts f.left + Point.new(1).label + f.right
puts Point::Formatter.name
