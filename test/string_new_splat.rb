# String.new with a splatted argument list: the content is the splat's one
# element (a copy), none is the empty String, and two or more raise
# ArgumentError, as for the written-out call. The splatted Array was taken
# for the content itself and the C did not compile.

def build(*a) = String.new(*a)

s = build("abc")
s << "d"
p s, s.frozen?
p build, build.frozen?
begin
  build("a", "b")
rescue ArgumentError => e
  p e.message
end
lit = "lit"
c = build(lit)
p c, c.equal?(lit)
args = ["xy"]
t = String.new(*args)
t << "z"
p t, args
p String.new(*[], encoding: "BINARY").encoding
