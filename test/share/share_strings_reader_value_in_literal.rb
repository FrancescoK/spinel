# A reader's String put into a Hash or Array literal is the reader's String
# itself, under --share-strings: through one class's attr reader of a field
# that is a box, and through a boxed receiver whose classes answer the
# reader with a field or a method. A change through the original name shows
# through the literal, as in CRuby.
class Req
  attr_accessor :host
  def initialize(h) = @host = h
end
class Other
  def host = @h
  def initialize(h) = @h = h
end

s = String.new("example.com")
r = rand < 2 ? Req.new(s) : Other.new(s)
opts = { host: r.host, port: 80 }
list = [r.host]
s << ":8080"
p opts[:host], list[0], opts[:host].equal?(s)

t = String.new("b.example")
q = rand < 2 ? Other.new(t) : Req.new(t)
o2 = { host: q.host }
t << "/x"
p o2[:host]

u = String.new("one")
k = Req.new(u)
k.host = rand < 2 ? u : 1
o3 = { host: k.host }
u << "!"
p o3[:host]
