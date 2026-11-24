# A top-level def that reads its receiver through a bare Object or Kernel method, takes arguments through a Method,
# reads self in a default, or takes a block whose answers differ by call: the bare names are calls on the receiver
# (a bare unknown name is still a NameError), a Method of the def binds its arguments after the receiver, and a def
# that takes a block is one body for every receiver.

def to_s_of = to_s
def inspect_of = inspect
def int_p = is_a?(Integer)
def nil_p = nil?
def frozen_of = frozen?
def same_id = object_id == self.object_id
def eq_self(o) = equal?(o)
def size_of = size

class C
  def go_frozen = frozen_of
  def go_id = same_id
  def go_size = size_of
end

p [5.send(:to_s_of), :s.send(:inspect_of), 5.send(:int_p), nil.send(:nil_p), to_s_of, int_p]
p [C.new.go_frozen, C.new.go_id, same_id, 5.send(:frozen_of)]
p [[1, 2].send(:size_of), { a: 1 }.send(:size_of), (+"abc").send(:size_of)]
o = Object.new
p [o.send(:eq_self, o), 5.send(:eq_self, 5)]
begin; size_of; rescue NameError => e; p [e.class, e.message]; end
begin; C.new.go_size; rescue NameError => e; p [e.class, e.message]; end

# a Method of a def with arguments, on receivers of every kind
def ar(a) = [self.class, a]
def ds(x = self) = x
p [[1].method(:ar).call(7), 5.method(:ar).call(7), nil.method(:ar).call(7), :y.method(:ar).call(7)]
p [{ k: 1 }.method(:ar).call(7), 1.5.method(:ar).call(7), (+"s").method(:ar).call(7)]
args = [1]
p [1].method(:ar).call(*args)
m = [1].method(:ar)
p [m.call(7), m.to_proc.call(9)]
p [5.send(:ds), :s.method(:ds).call, "q".method(:ds).call, nil.method(:ds).call]

# a def that takes a block, called with blocks whose answers differ
def bp(&b) = b.call(self)
class C
  def go_bp = bp { |s| s.class }
end
p C.new.go_bp
p 5.send(:bp) { |s| s + 1 }
p bp { |s| s.class }

# a super whose chain ends at Object's private def runs it on the method's
# self: in a subclass's chain, from a block, through a module, an ivar of
# the receiver, a forwarding super
def me_sup = self
def who_sup(x = 1) = [self.class, x]
def iv_sup = @iv
class SupC
  def me_sup = [:c, super.equal?(self)]
  def who_sup(x) = [:c, super]
  def blk = [1].map { |_| me_sup }
end
class SupD < SupC
  def me_sup = [:d, super]
end
module SupM
  def who_sup(x) = [:m, super(x + 1)]
end
class SupE
  include SupM
  def initialize = @iv = :e_iv
  def iv_sup = [:e, super]
end
class SupF
  def who_sup(*) = [:f, super]
end
class SupG
  def who_sup(x) = [1].map { |_| super(x) }.first
end
o = SupC.new
p o.me_sup, o.who_sup(3), o.blk, SupD.new.me_sup
p SupE.new.who_sup(5), SupE.new.iv_sup, SupF.new.who_sup(7), SupG.new.who_sup(9)
p me_sup.inspect, who_sup
