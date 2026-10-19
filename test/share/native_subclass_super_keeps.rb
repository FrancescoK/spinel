# A subclass of StringIO hands the String it is given on to the class's
# constructor through super, or to StringIO#string= through super: the
# instance keeps that String itself from then on, as CRuby's does, so a
# write through the instance shows in the String and #string answers it.
# The share walk took a super into a native class's binding as a call it
# does not follow, so the parameter was a byte-only copy and the codegen
# called the copying forms (sp_StringIO_init_s, sp_StringIO_set_string);
# the instance now holds the String (its self holder), and the super takes
# the binding's handle form (#9258).
require 'stringio'

class LogIO < StringIO
  attr_reader :sets
  def initialize(buf)
    super(buf)
    @sets = 0
  end
  def string=(v)
    @sets += 1
    super(v)
  end
  def body = string
end

s = String.new("ab")
io = LogIO.new(s)
io.seek(0, IO::SEEK_END)
io << "cd"
p s
t = String.new("x")
io.string = t
io.seek(0, IO::SEEK_END)
io << "y"
p t
p io.body.equal?(t)
p io.sets

# the forwarding super, and a mode beside the String
class TailIO < StringIO
  def initialize(buf) = super
end
class AppendIO < StringIO
  def initialize(buf) = super(buf, "a")
end
u = String.new("12")
TailIO.new(u).tap { |o| o.seek(0, IO::SEEK_END); o << "3" }
p u
v = String.new("45")
AppendIO.new(v) << "6"
p v

# no initialize of its own: the class's constructor keeps the String, and
# the subclass's string= hands the next one on
class CountIO < StringIO
  attr_reader :sets
  def string=(w)
    @sets = (@sets || 0) + 1
    super(w)
  end
end
w = String.new("ab")
c = CountIO.new(w)
c.seek(0, IO::SEEK_END)
c << "cd"
p w
x = String.new("x")
c.string = x
c.seek(0, IO::SEEK_END)
c << "y"
p x
p c.string.equal?(x)
p c.sets
