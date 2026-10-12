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

# a module's protected attr, called from another class that includes the
# module (directly, through a module, or through a superclass), whatever
# that class's own method of the name is
module Shared
  protected
  attr_accessor :s
end

class Holder
  include Shared
  def initialize; @s = nil; end
end

class Peer
  include Shared
  def poke(h); h.s ||= 6; h.instance_variable_get(:@s); end
end

class OwnPeer
  include Shared
  def s; :own; end
  def poke(h); h.s &&= 8; h.instance_variable_get(:@s); end
end

module Wrap
  include Shared
end

class WrapPeer
  include Wrap
  def poke(h); h.s ||= 9; h.instance_variable_get(:@s); end
end

class PeerKid < Peer
  def poke2(h); h.s ||= 3; h.instance_variable_get(:@s); end
end

# a class method's self is the class: an instance of a module it extends
class Extender
  extend Shared
  def self.poke(h); h.s ||= 4; h.instance_variable_get(:@s); end
end

class Includer
  include Shared
  def self.poke(h); h.s ||= 5; rescue NoMethodError; :raised; end
end

filled = Holder.new
filled.instance_variable_set(:@s, 1)
p Peer.new.poke(Holder.new), OwnPeer.new.poke(filled)
p WrapPeer.new.poke(Holder.new), PeerKid.new.poke2(Holder.new)
p Extender.poke(Holder.new), Includer.poke(Holder.new)

# a nil number reader under a writer that stores something else: `&&=`
# answers the reader's nil, boxed
class Sized
  attr_reader :n
  def initialize; @n = 1; end
  def n=(v); @n = v.size; end
  def clear; @n = nil; end
end

sz = Sized.new
sz.clear
r = (sz.n &&= "abc")
p r, sz.n
sz2 = Sized.new
sz2.clear
r = (sz2.n ||= "xy")
p r, sz2.n
