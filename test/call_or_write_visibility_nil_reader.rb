# `||=` and `&&=` through a reader/writer pair: a half the caller may not
# call raises NoMethodError before anything is stored, and a generated
# reader of a number ivar sees its nil.
def try
  r = yield
  [:stored, r]
rescue NoMethodError => e
  [:raised, e.class]
end

class Counter
  attr_reader :n

  def initialize
    @n = nil
  end

  def n=(v)
    @n = v + 1
  end
end

c = Counter.new
p(c.n ||= 1)
p(c.n ||= 5)
p(c.n &&= 7)
p c.n

class Guarded
  attr_reader :v

  def initialize
    @v = nil
  end

  private

  def v=(x)
    raise "unreachable" if x == 99
    @v = x
  end
end

class GuardedKid < Guarded
end

p try { Guarded.new.v ||= 1 }, try { GuardedKid.new.v ||= 99 }

class Fields
  attr_accessor :q
  private :q=

  def initialize(q)
    @q = q
  end
end

f = Fields.new(5)
p try { f.q ||= 6 }, try { f.q &&= 7 }, f.q
g = Fields.new(nil)
p try { g.q &&= 8 }, try { g.q ||= 9 }, g.q

class Hidden
  def initialize
    @z = nil
  end

  def z=(x)
    @z = x
  end

  private

  def z
    @z
  end
end

p try { Hidden.new.z ||= 3 }

class Kin
  def initialize
    @k = nil
  end

  def k=(x)
    @k = x
  end

  def fill(o)
    o.k ||= 4
  end

  protected

  def k
    @k
  end
end

class KinKid < Kin
end

kid = KinKid.new
p try { Kin.new.k ||= 1 }, try { Kin.new.fill(kid) }

guarded = Guarded.new
begin
  guarded.v ||= 1
rescue NoMethodError => e
  p e.receiver.equal?(guarded), e.name
end
