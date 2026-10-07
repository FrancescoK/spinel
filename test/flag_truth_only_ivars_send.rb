# An ivar read only for its truthiness keeps the object written into it
# when the program can reach an ivar by name through `send`: the reflection
# method named by a Symbol, or a method name computed at run time
# (which may name a method whose value is the ivar's).

class C
  def initialize = (@v = false; @m = [1])
  def inspect = "#<C>"
  def load = (@v ||= @m.dup; nil)
  def t = (@v ? 1 : 0)
  def v = @v
end
c = C.new
c.load
p c.t
p c.send(:instance_variable_get, :@v)
name = "u".succ
p c.public_send(name)
