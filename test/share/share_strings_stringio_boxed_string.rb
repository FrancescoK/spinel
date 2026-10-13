# Flag-only. StringIO#string on a boxed receiver (an Array element that may
# also be another class's object) answers the String the StringIO is opened
# on, as CRuby's does: a change through the answer shows in the StringIO
# and in the String's other names, and a write through the StringIO (write,
# print, putc, truncate, `<<`) shows in the answer. Also the answer handed
# on as an argument, an Array element, a Hash value, an ivar and a global,
# a StringIO opened on no String, a grown String, and a StringIO over a
# frozen literal, whose #string is that frozen String and takes no write
# (typed or boxed). No class of the program has a #string of its own (for
# one that does: share_strings_stringio_boxed_string_mixed.rb).
require "stringio"
class Plain
  def token = String.new("fresh")
end
def app(s) = s << "!"

o = [Plain.new, StringIO.new(+"x")][1]
tk = o.string
saved = tk
tk << "-after"
puts saved
p o.string, o.read

s = +"base"
o = [1, StringIO.new(s)][1]
t = o.string
s << "1"
t << "2"
o.write("W")
p s, t, t.equal?(s)

o = [1, StringIO.new(+"ab")][1]
tk = o.string
o.write("Z")
o.print("P")
o.putc("C")
p tk
o.truncate(1)
p tk
o.rewind
o << "Q" << "R"
p tk, o.read
tk << "!"
o << "S"
p tk, o.string

o = [nil, StringIO.new(+"ab")][1]
t = o.string
t << "cd"
p o.read
t.upcase!
o.rewind
p o.read, o.string

o = [:a, StringIO.new][1]
t = o.string
t << "e"
o.print "x"
p t, o.string

o = [1, StringIO.new(+"m")][1]
app(o.string)
a = [o.string]
a[0] << "a"
h = { k: o.string }
h[:k] << "h"
@iv = o.string
@iv << "i"
$gv = o.string
$gv << "g"
p o.string

o = [1, StringIO.new(+"x")][1]
3.times { |i| t = o.string; t << i.to_s; GC.start }
t = o.string
t << "a" * 3000
p o.string.size, o.string[0, 4]

io = StringIO.new("lit")
t = io.string
p t.frozen?
begin
  io.write("x")
rescue IOError => e
  p e.message
end
o = [1, StringIO.new("lit")][1]
u = o.string
p u.frozen?
u2 = +u
u2 << "!"
p o.string, u2
