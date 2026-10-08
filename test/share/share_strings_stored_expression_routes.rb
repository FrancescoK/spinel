# A receiver-returning expression keeps its handle when stored as an element.
s = +"a"
a = []
a << (s << "x")
s << "y" * 100
p [s.size, a[0].size]

def render(io)
  io << "["
  yield io
  io << "]"
  io
end
out = +""
r = render(out) { |v| v << "z" * 100 }
r << "!"
p [out.size, r.size]
