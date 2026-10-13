# method(:puts), method(:p) and the other output functions take any number
# of arguments of any kind. Held in an ivar, where no call site is counted,
# such a Method's wrapper took one parameter typed from every boxed call of
# the program, and a splatted call on a boxed block anywhere made it an
# Integer: the String passed later found no way in, and the call raised
# NoMethodError for the Method.
class Relay
  def initialize(&blk) = @blk = blk
  def call(*args) = @blk.call(*args)
end

class P
  def initialize(writer: nil) = @writer = writer
  def report(n) = @writer&.call("x#{n}")
end

Relay.new { |a| p a }.call(1)
Relay.new(&method(:p)).call(2)
P.new(writer: ->(s) { puts s }).report(1)
P.new(writer: method(:puts)).report(3)
w = method(:print)
w.call("a", 1, :b, "\n")
q = method(:p)
p q.call(1, "two")
