# `&.` on a method the program adds to String that changes self in place:
# such a method takes its receiver as the handle every name holds, so the
# change shows through them. The nil guard of a reopened builtin's method
# leaves that call as it was unless its receiver is a read, which the call
# reads again.

class String
  def add!(x)
    self << x
    self
  end
  def idem = self
end

class Rec
  attr_accessor :name
  def initialize(n) = @name = n
end

# the receiver is a reader's answer
r = Rec.new(+"n")
p r.name&.add!("d")
p r.name

# the receiver is a chain
s = +"c"
p s&.idem&.add!("1")
p s

# a local that is nil, and one that is not
t = ARGV.size > 5 ? +"t" : nil
p t&.add!("x")
u = ARGV.size > 5 ? nil : +"u"
p u&.add!("x")
p u
