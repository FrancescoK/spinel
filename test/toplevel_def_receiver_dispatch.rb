# A top-level def is a private method of Object whose self is the receiver
# that invokes it: through a Method, a send, a block-taking send, a Method
# taken inside an instance method, and an instance_eval block. The String
# argument checks that the receiver's own class reaches the def and that the
# argument keeps its identity across the Method call.

def app(v)
  v << self.class.name
  v
end

def tn = self.class.name
def me = self
def nxt = self + 1
def len = size
def yd = yield(self)
def tf(s, &b)
  s << b.call(self.class.name)
  [self.class.name, b.nil?]
end

class Desc
  def run
    $g = +"x"
    f = ARGV.empty? ? method(:app) : ->(v) { v }
    r = f.call($g)
    p [$g, r.equal?($g)]
  end

  def direct = method(:tn).call
  def mapped = [+"a", +"b"].map(&method(:app))
  def held = @m = method(:tn)
  def later = @m.call
end

Desc.new.run
d = Desc.new
p d.direct
p d.mapped
d.held
p d.later

# a Method of the top-level def on any receiver
p [5.method(:tn).call, nil.method(:tn).call, :s.method(:tn).call, 2.5.method(:tn).call]
p [[1, 2].method(:tn).call, { a: 1 }.method(:tn).call, d.method(:tn).call]
o = Object.new
p [o.method(:me).receiver.equal?(o), o.method(:me).call.equal?(o)]
p method(:tn).call, method(:tn).owner

# a send, with and without a block, to a builtin and to a program object
p [5.send(:nxt), 5.method(:nxt).call]
p [[1, 2].send(:len), (+"abc").send(:len), { a: 1 }.send(:len)]
p :sym.send(:yd) { |s| s }
$g = +"x"
r = Desc.new.__send__(:tf, $g) { |n| n.downcase }
p [r, $g]

# a boxed receiver, from a container of mixed values
[1, :b, "c", nil, d, 2.5].each { |v| p v.send(:tn) }
[1, :b, "c", nil, d, 2.5].each { |v| p v.method(:tn).call }

# an instance_eval block runs the def on the rebound receiver
class C; end
c = C.new
p c.instance_eval { me }.equal?(c)
p c.instance_exec(7) { |x| [me.equal?(c), x] }

# a Method taken inside a reopened nil class
class NilClass
  def grab = method(:tn)
end
p nil.grab.call

# a def that takes a block, run on several receivers with blocks of other types
def bp(&b) = [b.call, self.class.name]
class Desc
  def two = [bp { 1 }, bp { "s" }]
end
p Desc.new.two
p 5.send(:bp) { :a }

# bind of a Method taken on the def, to any value
u = d.method(:tn).unbind
p [u.bind(Object.new).call, u.bind(nil).call, u.bind(5).call, u.bind("s").call, u.bind(2.5).call]
# a public top-level writer called on a boxed receiver
def dw=(v); $dw = [self.class, v]; end
public :dw=
dx = ARGV.empty? ? 5 : "s"
dx.dw = 1
p $dw
dy = ARGV.empty? ? "t" : 2
dy.dw = 2
p $dw
# a yielding top-level def sent with no block runs until its yield raises
def dy1(x) = yield(x)
def dy2(x)
  yield(x) + 1
rescue LocalJumpError
  [:lje, x]
end
def dy3 = block_given? ? yield : :noblk
class DY; def go(n, v) = send(n, v); end
DYN = %i[dy1 dy2]
p((DY.new.go(DYN[0], 1) rescue $!.class))
p DY.new.go(DYN[1], 1)
p DY.new.send(:dy3), 5.send(:dy3), nil.send(:dy3), "s".send(:dy3)
p 5.send(:dy2, 4), nil.send(:dy2, 4)
p [DY.new, 3, nil].map { |o| o.send(:dy2, 7) }
da, db = DY.new.send(:dy2, 1), 2.send(:dy2, 2)
p [da, db]
