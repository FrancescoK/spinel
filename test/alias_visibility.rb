# An alias is its own method: changing the visibility of the alias leaves the
# original alone and the other way round, and an alias copies the visibility
# its target has at the alias.
def chk
  yield
  p :public
rescue NoMethodError
  p :private
end

class A
  def z = 1
  alias pz z
  private :pz
  alias_method :qz, :z
  protected :qz
  def call_q(o) = o.qz
  attr_reader :r
  alias rr r
  private :rr
  def initialize; @r = 5; end
  def via = rr
  def z2 = 2
  private alias_method :pz2, :z2
end
chk { A.new.pz }
chk { A.new.qz }
p A.new.call_q(A.new)
chk { A.new.rr }
p A.new.via
p A.new.z
chk { A.new.pz2 }
p A.new.z2
p A.private_method_defined?(:pz), A.public_method_defined?(:z)
p A.protected_method_defined?(:qz)

class P
  def base = 7
end
class C < P
  alias cb base
  private :cb
  def use = cb
end
chk { C.new.cb }
p C.new.use
p P.new.base

module Mo
  def mm = 9
  alias pmm mm
  private :pmm
end
class D
  include Mo
end
chk { D.new.pmm }
p D.new.mm

class E
  private def pe = 2
  alias_method :ape, :pe
end
chk { E.new.ape }

class F
  def f = 1
  alias ff f
  private :f
end
p F.new.ff
chk { F.new.f }
