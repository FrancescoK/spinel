# StringIO#string= reopens the StringIO on the String it is handed, read
# from its start: a write overwrites from there, and #string answers that
# String. A frozen String takes no write (IOError, as CRuby run with frozen
# string literals), one opened on a frozen String takes none even after
# #string= hands it another, and a frozen String opened for writing is
# Errno::EACCES. nil is a TypeError. Typed and boxed.
require "stringio"
def try(tag)
  p [tag, yield]
rescue IOError, TypeError, SystemCallError => e
  p [tag, e.class, e.message]
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
%w[write print puts putc << truncate].each do |m|
  try(m) do
    case m
    when "write" then lit.write("x")
    when "print" then lit.print("x")
    when "puts" then lit.puts("x")
    when "putc" then lit.putc("x")
    when "<<" then lit << "x"
    else lit.truncate(1)
    end
  end
end
p lit.read
lit.string = +"m"
try(:reopened) { lit << "!" }
try(:w) { StringIO.new("lit", "w") }
o = [1, StringIO.new(+"ab")][1]
o.string = +"boxed"
o << "B"
p o.string
f = [1, StringIO.new("lit")][1]
try(:boxed_lit) { f << "x" }
p f.string
