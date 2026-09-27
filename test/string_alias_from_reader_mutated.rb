# An alias taken FROM a reader and mutated through carries back to the ivar.
# The converse of #5112, which fixed the alias taken BEFORE a mutation that
# goes through the reader. Here the mutation goes through the ALIAS: the local
# saw it, the object kept the old string, and nothing said so.
class C
  attr_reader :name
  def initialize; @name = +"ab"; end
end

c = C.new
t = c.name
t << "!"
p t
p c.name

# #5112's direction still holds: an alias taken before a mutation through the
# reader sees it too
d = C.new
x = d.name
d.name << "!"
p x
p d.name

# the shape a buffer-holding object is used through, which is what a renderer
# is built on: the buffer is reached through two objects and two aliases
class State
  attr_reader :buffer
  def initialize; @buffer = +""; end
end
class View
  def initialize; @state = State.new; end
  def div
    st = @state
    buf = st.buffer
    buf << "<div>"
    buf << "</div>"
  end
  def to_s; @state.buffer; end
end
v = View.new
v.div
p v.to_s
