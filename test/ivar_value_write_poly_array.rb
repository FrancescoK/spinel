# A typed array written to an ivar the program widened to the general Array
# (a nil pushed through its reader) is rebuilt as one where the write is a
# value too: an endless method's `(@a = [z])`, a `@o ||= [1]` tail. The
# statement form did so already.

class B
  attr_reader :a, :f, :s, :o
  def initialize(z) = (@a = [z])
  def setf(z) = (@f = [z])
  def sets(z) = @s = [z]
  def seto = (@o ||= [1])
end
b = B.new(1)
b.a << nil
b.setf(1.5)
b.f << nil
b.sets("x")
b.s << nil
b.seto
b.o << nil
p b.a, b.f, b.s, b.o
$g = nil
def sg = ($g = [1])
sg
$g << nil
p $g
