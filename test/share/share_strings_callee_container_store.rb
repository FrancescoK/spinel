# spinel: gc-minor
# A callee stores the same String into its caller's Array or Hash.
class CalleeStore
  attr_reader :text
  def initialize = (@text = +"n")
  def keep(a) = (a << text)
  def keep_self(a) = (a << self.text)
  def keep_ivar(h) = (h[:v] = @text)
  def read_text = @text
  def keep_method(a) = (a << read_text)
  def keep_index(a) = (a[0] = text)
end
k = CalleeStore.new
a = []
k.keep(a)
a[0] << "!"
p [k.text, a[0], k.text.equal?(a[0])]
b = []
k.keep_self(b)
b[0] << "?"
p [k.text, b[0], k.text.equal?(b[0])]
h = {}
k.keep_ivar(h)
h[:v] << "."
p [k.text, h[:v], k.text.equal?(h[:v])]
c = []
k.keep_method(c)
c[0] << ":"
p [k.text, c[0], k.text.equal?(c[0])]
d = []
k.keep_index(d)
d[0] << ";"
p [k.text, d[0], k.text.equal?(d[0])]
def put(a, s) = (a << s)
t = +"t"
e = []
put(e, t)
e[0] << "#"
p [t, e[0], t.equal?(e[0])]
