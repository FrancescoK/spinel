# A subclass constructed alone, whose parent's methods append to a String
# held in an ivar, has the parent's String slot: the caller's buffer is the
# one appended to, as with the parent itself. The subclass was left a value
# slot and its layout refused, or (once laid out) took a copy. PP <
# PrettyPrint is this shape.
class Writer
  def initialize(out) = @out = out
  def add(s) = @out << s
  def out = @out
end

class Plain < Writer; end

class Own < Writer
  def initialize = super(String.new)
end

buf = String.new
Plain.new(buf).add("a")
puts buf

w = Own.new
w.add("b")
w.add("c")
puts w.out

both = String.new
Writer.new(both).add("x")
Plain.new(both).add("y")
puts both
