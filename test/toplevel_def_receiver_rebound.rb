# A top-level def that reads its self runs on the self of the code that calls it: the receiver an instance_eval,
# instance_exec or class_eval block runs on (a builtin value, nil, a Class, a Module, nested ones), a reopened
# builtin's receiver, the version a redefinition made, and a block handed to a one-body def.
class K
  def label = :k1
end
module Mo; end
@iv = :main_iv
def k = self
def kc = self.class
def m = instance_variable_get(:@iv)

p K.method(:k).call
p Mo.method(:k).call
p [5.instance_eval { k }, "s".instance_exec { k }, :sy.instance_exec(1) { |a| [k, a] }]
p [K.instance_eval { k }, Mo.class_eval { k }, K.class_eval { m }, nil.instance_eval { k }]
p [1].instance_eval { k }
p 5.instance_eval { [kc, :s.instance_eval { kc }, kc] }
p [1].instance_eval { map { kc } }

class Integer
  def go = m
  def gk = k
end
p [5.go, 5.gk, 7.0.then { 3.gk }]
class String
  def go2 = k
end
p "q".go2

def app = self << "x"
def app2 = concat("y")
t = +"q"
p t.instance_eval { app; app2 }
p t

v1 = 5.send(:kc)
def kc = [self.class, 2]
p [v1, 5.send(:kc)]

def lb = label
a = K.new.send(:lb)
class K
  def label = :k2
end
p [a, K.new.send(:lb)]

def bp(&b) = [b.call, self.class.name]
class K
  def run = bp { self.class.name }
end
p [K.new.run, :s.send(:bp) { 1 }]

def sz = size
class K
  def go = sz
end
begin; sz; rescue NameError => e; p e.class; end
begin; K.new.go; rescue NameError => e; p e.class; end

def yr
  yield
rescue NoMethodError => e
  [e.class]
end
ys = ARGV.empty? ? "yr".to_sym : :size
p "a".send(ys) { 1 }
p "a".send(:yr) { :b }
kn = ARGV.empty? ? "k".to_sym : :size
begin; p ["a"].map(&kn); rescue NoMethodError => e; p e.message; end
begin; p nil.public_send(kn); rescue NoMethodError => e; p e.message; end
public def pk = [:pub, self.class]
pn = ARGV.empty? ? "pk".to_sym : :size
p [5.public_send(pn), [:s].map(&pn)]
so = Object.new
def so.q = 2
begin; so.public_send(:k); rescue NoMethodError => e; p e.message.sub(/0x\h+/, "0x"); end

def rh = [:rh, self.class]
def rv(v) = [self.class, v]
class RN
  def go = [nil.instance_eval { rh }, 5.instance_eval { rh }, "s".instance_exec(2) { |x| [rh, rv(x)] }]
  def go2 = nil.instance_eval { [1].map { rh } }
  def self.cg = [nil.instance_eval { rh }, 5.instance_exec(1) { |x| [rh, x] }, "s".instance_eval { rv(3) }]
  class << self
    def sc = nil.instance_eval { rh }
  end
end
p RN.new.go, RN.new.go2, RN.cg, RN.sc
p [nil, 1, "t"].map { |v| v.instance_eval { rh } }
# a bare call in a block run on another receiver asks that receiver's chain, not the enclosing class's own method
class RO
  def rh = :own
  def go = [1.instance_eval { rh }, :s.instance_exec(1) { |x| [rh, x] }, [1].instance_eval { rh }, 2.5.instance_eval { rh }, instance_eval { rh }]
  define_method(:dm) { rh }
end
p RO.new.go, RO.new.dm
