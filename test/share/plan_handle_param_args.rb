# Under --share-strings a String bound to a parameter that is the shared
# handle -- a method's, or a block's that the block changes in place -- is
# the caller's String wherever the caller has it as one: a variable, a
# variable the call ran ahead of a later argument that writes it, a route
# over one (`then`, `String(s)`, an append), a write in value position, a
# keyword a yield hands its block (`yield text: self`), a box. A String no
# other name holds (a literal's copy, a new String) is a new one, which
# the callee may change on its own.
def app(t) = (t << "!"; t)
def keep(v) = (@k = v)
s = +"a"
t = s
app(s)
app(t << "x")
app(s.then { |z| z })
app(String(s))
keep(s)
s << "?"
p s, t, @k, @k.equal?(s)

# a variable a later argument writes is bound as it was read
def two(a, b) = (a << "1"; [a, b])
u = +"u"
w = u
p two(u, (u = +"v"; 2)), u, w

# a write in value position, into a method's and a block's parameter
x = nil
app(x = +"x")
p x
def yw = yield(@w = +"w")
yw { |v| v << "!" }
p @w

# a keyword a yield hands its block: the receiver itself
class String
  def kw_yield
    yield text: self
    self
  end
end
k = +"ab"
r = k.kw_yield { |text:| text << "!" }
p k, r.equal?(k)

# a new String: the block's own
def words
  yield "a" + "b"
  yield "c".dup
  yield +"lit"
end
out = []
words { |q| q << "!"; out << q }
p out

# a box holding the String, and nil
def nb(v) = (v.nil? ? :none : app(v))
bx = [s, 1][ARGV.size]
p nb(bx), s
p nb(nil)

# through a Method, which makes the parameter the handle
m = method(:app)
y = +"m"
m.call(y)
p y, m.call(+"q"), app(+"z")
