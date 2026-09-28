# `obj.buf << x` in VALUE position, where the reader's ivar has become the
# shared handle. The statement form asks strbuf_slot_ref directly and always
# worked; the value form matched no arm (the String rows are gated on
# TY_STRING and a handle reader answers TY_STRBUF) and was refused outright.
class St
  def initialize(o)
    @buffer = +""
    @output_buffer = o
  end
  attr_reader :output_buffer, :buffer
end

def run(buffer)
  st = St.new(buffer)
  st.buffer << "x"
  st.output_buffer << st.buffer   # tail position: the method's value
end
p run(+"")

# the same append consumed as a local, and as a statement
def run2(buffer)
  st = St.new(buffer)
  st.buffer << "y"
  r = st.output_buffer << st.buffer
  p r
  st.output_buffer << "!"
  nil
end
b = +"a"
run2(b)
p b

# concat and prepend take the same route
def run3(buffer)
  st = St.new(buffer)
  st.buffer << "z"
  p(st.output_buffer.concat(st.buffer))
  p(st.output_buffer.prepend("<"))
end
run3(+"")
