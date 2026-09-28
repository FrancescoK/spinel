# The value of `obj.buf << x`, where the reader hands out the shared handle,
# is the receiver itself: a local holding it is the same string as obj.buf.
class St
  def initialize(o)
    @buffer = +""
    @out = o
  end
  attr_reader :out, :buffer
end

# a local holding the append's value aliases the buffer
def alias_local(o)
  st = St.new(o)
  st.buffer << "x"
  r = st.out << st.buffer
  r << "Z"
  st.out << "!"
  p st.out, r, r.equal?(st.out)
end
alias_local(+"")

# a chained append assigned to a local, and chains in statement position
def chained(o)
  st = St.new(o)
  r = st.out << "a" << "b"
  r << "c"
  (st.out << "1") << "2"
  st.out << "3" << "4"
  p st.out, r, r.equal?(st.out)
end
chained(+"")

# concat and prepend answer the receiver as well
def concat_prepend(o)
  st = St.new(o)
  st.buffer << "q"
  c = st.out.concat(st.buffer)
  c << "C"
  pr = st.out.prepend("<")
  pr << ">"
  p st.out, c.equal?(pr)
end
concat_prepend(+"m")

# replace and clear answer the receiver too
def replace_clear(o)
  st = St.new(o)
  st.buffer << "q"
  r = st.out.replace("qq")
  r << "?"
  p st.out, r.equal?(st.out)
  c = st.out.clear
  c << "c"
  p st.out, c.equal?(st.out)
end
replace_clear(+"ab")

# tail position: the method's value is the appended string
def tail(o)
  st = St.new(o)
  st.buffer << "t"
  st.out << st.buffer
end
p tail(+"s")
buf = +"b"
p tail(buf)
p buf
