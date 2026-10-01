# A `<<` whose value is used still stores the longer String back into the
# local or ivar it starts at, when that slot holds a plain boxed String (one
# that also holds other kinds of value): a block's last line, `r = (x << y)`,
# `p(x << y)`. A raise later in the chain keeps the appends done so far.

def headers_into(out, headers, body)
  headers.each { |k, v| out << k << ": " << v << "\r\n" }
  body.each { |c| out << c }
  out
end
slot = [1, +"HTTP/1.1 200 OK\r\n"][1]
p headers_into(slot, [["a", "1"], ["b", "2"]], ["hi"])

x = [1, +"x"][1]
r = (x << "1" << "2")
p [x, r]

y = [1, +"y"][1]
p(y << "!")
p y

def boom = raise("boom")
z = [1, +"z"][1]
begin
  p(z << "a" << boom)
rescue RuntimeError
end
p z

class Holder
  def initialize = @s = [1, +"i"][1]
  def add = (@s << "v" << "w")
  def s = @s
end
h = Holder.new
p h.add
p h.s

arr = [[1], 2][0]
p(arr << 3)
p arr
n = [2, "s"][0]
p(n << 3)
p n

# the argument replaces the String: the new one stays, as in CRuby
class Swap
  def initialize = @buf = [1, +"b"][1]
  def take
    @buf = [1, +"new"][1]
    "x"
  end
  def run = (r = (@buf << take); [@buf, r])
  def run_statement
    @buf << take
    @buf
  end
end
p Swap.new.run
p Swap.new.run_statement
