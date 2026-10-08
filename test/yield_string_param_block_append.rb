# spinel: share
# A String yielded to a block that appends to its parameter: the append has
# to reach the yielded variable, and through it the caller's, the way a
# shared CRuby String would. Three faults met here: the usage pass typed the
# block parameter a string ARRAY from the `<<` (unified with the yield's
# String into poly, where `<<` built a new string), the parameter was bound
# by copy so a grown buffer left the yielded one behind, and a parameter the
# callee rebinds was never aliased at all, so an append BEFORE the rebind was
# lost too.
def fill(b)
  yield b
  b
end
buf = String.new("")
fill(buf) { |s| s << "z" }
p buf

def render(io)
  io << "["
  yield io
  io << "]"
  io
end
out = String.new("")
r = render(out) { |s| s << "x" }
p r
p out
p render(String.new("q")) { |s| s << "yy" }

# a rebind inside the callee is its own new binding: the caller keeps what
# was appended before it, the block appends to the new one
def render2(io)
  io << "["
  io = String.new("fresh")
  yield io
  io << "]"
  io
end
out2 = String.new("")
r2 = render2(out2) { |s| s << "y" }
p r2
p out2

# two yields of the same variable, and a block that only reads
def twice(io)
  yield io
  yield io
  io
end
acc = String.new("")
p twice(acc) { |s| s << "." }
p acc
p twice(acc) { |s| s.length }
