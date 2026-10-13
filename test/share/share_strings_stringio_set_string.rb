# Flag-only. StringIO#string= keeps the very String it is handed, as CRuby's
# does: a change to it through another name shows in the StringIO, a write
# through the StringIO shows in it, and #string answers it. The String kept
# before is the StringIO's no more. Handed a local, an ivar or a reader's
# answer, on a typed or a boxed StringIO. It reads from the start of the
# String; a frozen one takes no write, nor does a StringIO opened on a
# frozen String after #string= hands it another; nil, or an Integer in a
# box, is a TypeError.
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

def try(tag)
  yield
  puts "#{tag}: took it"
rescue IOError, TypeError => e
  puts "#{tag}: #{e.class}: #{e.message}"
end
io = StringIO.new(+"abc")
io.read(2)
r = (io.string = +"xyz")
p r, io.pos, io.read
io.rewind
io.write("Q")
p io.string
io.string = "frozen"
try(:frozen) { io << "x" }
p io.string.frozen?
io.string = +"thaw"
io << "T"
p io.string
try(:nil) { io.string = nil }
lit = StringIO.new("lit")
lit.string = +"m"
try(:reopened) { lit << "!" }
o = [1, StringIO.new(+"ab")][1]
o.string = +"boxed"
o << "B"
p o.string
v = [5, "s"][0]
try(:int) { o.string = v }
k = StringIO.new(+"ab")
kt = k.string
kt << ""
kt.freeze
try(:frozen_since) { k << "x" }
