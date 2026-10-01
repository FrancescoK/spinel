# A `<<` statement on a boxed local or ivar stores back only while the slot
# still holds the receiver, also when a user class defines its own `<<`
# (here Log): an argument that put a new String in the slot keeps it, and a
# raise later in a chain keeps the appends done so far.

class Log
  def initialize; @a = []; end
  def <<(x); @a << x; self; end
  def items = @a
end
lg = [1, Log.new][1]
lg << 1 << 2
p lg.items

class Swap
  def initialize = @buf = [1, +"b"][1]
  def take
    @buf = [1, +"new"][1]
    "x"
  end
  def run
    @buf << take
    @buf
  end
  def run_chain
    @buf << "y" << take
    @buf
  end
end
p Swap.new.run
p Swap.new.run_chain

s = [1, +"s"][1]
s << (s = [1, +"t"][1]; "!")
p s

def boom = raise("boom")
u = [1, +"u"][1]
begin
  u << "1" << boom << "2"
rescue RuntimeError
end
p u
