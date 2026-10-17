# Flag-only. The value of `io.string = s` is the String it was handed, as for
# every attribute assignment, not a copy of it: kept in a variable, handed on
# as an argument, an element, a hash value, a method's answer (returned or
# its last expression), a block's value or the receiver of a chain, it is one
# String with s and with the String the StringIO now keeps, so a change
# through any of those names shows in the others. A new String handed over is
# the StringIO's too, and the value is that very String. A frozen one stays
# frozen.
require "stringio"

def append(z) = z << "?"
def set_tail(io, s)
  io.string = s
end
def set_returned(io, s)
  return (io.string = s)
end
def run_block = yield

io = StringIO.new
s = +"x"
r = (io.string = s)
r << "!"
p s, r.equal?(s), io.string

(io.string = s) << "1" << "2"
p s, io.string

t = +"t"
append(io.string = t)
p t, io.string

u = +"u"
arr = [io.string = u]
arr[0] << "+"
p u, arr[0].equal?(u), io.string

h = { k: (io.string = u) }
h[:k] << "-"
p u, io.string

v = +"v"
r = set_tail(io, v)
r << "*"
p v, r.equal?(v), io.string

w = +"w"
r = set_returned(io, w)
r << "*"
p w, r.equal?(w), io.string

q = +"q"
m = [1].map { io.string = q }
m[0] << "%"
p q, m[0].equal?(q), io.string

q2 = +"q"
r = run_block { io.string = q2 }
r << "%"
p q2, io.string

r = (io.string = +"new")
r << "!"
p r, io.string, r.equal?(io.string)

r = true ? (io.string = s) : nil
r << "#"
p s, io.string

r = nil || (io.string = s)
r << "&"
p s, io.string

p((io.string = s).size)
(io.string = s).upcase!
p s, io.string

a = +"a"
b = +"b"
r = (io.string = a)
io.string = b
r << "1"
p a, b, io.string, r.equal?(a)

z = +"z"
src = StringIO.new(z)
r = (src.string = a)
r << "2"
z << "3"
p z, a, src.string, r.equal?(a)

r = (io.string = "lit".freeze)
p r.frozen?, io.string.frozen?
begin
  io.write("x")
rescue IOError => e
  p e.class
end

class Holder
  def initialize; @io = StringIO.new; end
  attr_reader :io
  def set(s)
    r = (@io.string = s)
    r << "!"
    r
  end
end
hd = Holder.new
n = +"n"
r = hd.set(n)
p n, r.equal?(n), hd.io.string
r = (hd.io.string = n)
r << "?"
p n, hd.io.string

io.string = s
s << "stmt"
p io.string

# consumers that read the value as a String
k = +"k"
p "<#{io.string = k}>"
k << "1"
p io.string, k
p((io.string = k).dup)
p [1].map { "#{io.string = k}" }
case (io.string = k)
when "k1" then puts "case"
else puts "other"
end
p :ok if (io.string = k)
p :"#{io.string = k}"
k << "2"
p io.string

# the attribute's reader and writer through `||=` and `&&=`
oq = +"oq"
io.string ||= oq
p io.string.equal?(oq)
io.string &&= oq
oq << "!"
p io.string, io.string.equal?(oq)
