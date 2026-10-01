# A String yielded to a block whose parameter a lambda or proc inside
# captures and appends to: the append reaches the caller's String. The
# block is wrapped in a lambda that owns the captured parameter
# (desugar_block_capture_wrap), and that wrapper took a copy.
def y1(v) = yield(v)
u1 = +"a"
y1(u1) { |q| l = lambda { q << "#" }; l.() }
p u1

u2 = +"b"
y1(u2) { |q| pr = proc { q << "?" }; pr.call }
p u2

def y2(v)
  yield v
  yield v
end
u3 = +"c"
y2(u3) { |q| f = -> { q.concat("!") }; f.call }
p u3

# a block parameter that only reads keeps its copy, and the caller's
# String is unchanged
u4 = +"d"
y1(u4) { |q| g = -> { q + "x" }; p g.call }
p u4

# as before: an Array element, and the append made directly
u5 = +"e"
[u5].each { |q| h = -> { q << "%" }; h.call }
p u5
u6 = +"f"
y1(u6) { |q| q << "&" }
p u6

begin
  y1("lit") { |q| l = -> { q << "x" }; l.() }
rescue => e
  p e.class
end
