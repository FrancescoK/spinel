# Flag-only. StringIO#string= keeps the very String it is handed, as CRuby's
# does: a change to it through another name shows in the StringIO, a write
# through the StringIO shows in it, and #string answers it. The String kept
# before is the StringIO's no more. Handed a local, an ivar or a reader's
# answer, on a typed or a boxed StringIO.
require "stringio"
class Holder
  def initialize; @s = +"held"; end
  attr_reader :s
end
io = StringIO.new(+"ab")
old = io.string
old << "1"
s = +"new"
io.string = s
s << "!"
old << "2"
p io.read, io.string, old
io.write("W")
p s
t = io.string
t << "?"
p s, t.equal?(s)

o = [1, StringIO.new(+"ab")][1]
b = +"box"
o.string = b
b << "!"
p o.read
o.write("W")
p b

h = Holder.new
io.string = h.s
h.s << "!"
p io.string
@iv = +"ivar"
io.string = @iv
@iv << "?"
io << "I"
p io.read, @iv
