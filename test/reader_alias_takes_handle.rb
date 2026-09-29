# A local aliased from a reader over a shared handle, and only READ, holds
# the handle itself. The read handed out the sp_String *, but the node kept
# its String type, so the local's write took it for a const char * and wrapped
# it in sp_String_new_shared: a C compile error, and a garbage read wherever
# the C compiler let it through.
#
# The slot is shared here because a mutation went through an alias of ANOTHER
# object's reader, not through this object; an object that mutates the slot
# itself had its alias claimed by an earlier rule, which retypes the read.
class Binned
  attr_reader :bytes
  def initialize(bytes)
    @bytes = bytes
  end
end

class Ctx
  attr_reader :bytes
  def initialize(bytes)
    @bytes = bytes
  end
end

def fill(binned)
  w = binned.bytes
  w.setbyte(1, 7)
  w.setbyte(3, 2)
end

def sum(ctx)
  b = ctx.bytes
  s = 0
  i = 0
  while i < b.bytesize
    s += b.getbyte(i)
    i += 1
  end
  s
end

binned = Binned.new("\0" * 4)
fill(binned)
ctx = Ctx.new(binned.bytes)
p sum(ctx)
fill(binned)
binned.bytes.setbyte(0, 1)
p sum(ctx)
