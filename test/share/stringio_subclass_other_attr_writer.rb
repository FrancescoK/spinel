# Flag-only. Another class of the program with an attribute writer named
# `string` does not take a StringIO subclass's `string=`: the subclass has
# the class's own, as a StringIO does, in statement and value position.
require "stringio"

class Other
  attr_writer :string
  def peek = @string
end

class Plain < StringIO; end

o = Other.new
o.string = "o"
p o.peek

io = Plain.new(+"abc")
s = +"x"
io.string = s
s << "!"
p io.string

r = (io.string = +"y")
r << "?"
p r, io.string

def set(io, v) = (io.string = v)
t = set(io, +"z")
t << "#"
p t, io.string

io.string ||= +"q"
p io.string

plain = StringIO.new
plain.string = +"plain"
p plain.string
