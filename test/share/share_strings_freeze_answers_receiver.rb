# String#freeze answers its receiver, now frozen: the result is the same
# object, whatever name keeps it (a local, an ivar, a global, an Array or a
# Hash value, a method's return). A frozen literal's freeze is that
# literal; dup.freeze, -s and +s are the controls that answer other Strings.
def attempt(s)
  s << "x"
  "mutated"
rescue FrozenError
  "FrozenError"
end

def frozen_of(s) = s.freeze

class Keeper
  attr_reader :r
  def initialize(s)
    @s = s
    @r = s.freeze
  end
  def same? = @r.equal?(@s)
  def kept = @r
  def source = @s
end

# a local
s = +"abc"
r = s.freeze
puts r.equal?(s)
puts r.frozen?
puts s.frozen?
puts attempt(r)
puts attempt(s)

# an ivar
k = Keeper.new(+"iv")
puts k.same?
puts k.r.frozen?
puts k.source.frozen?
puts k.kept.equal?(k.source)
puts attempt(k.r)

# a global
s = +"gl"
$g = s.freeze
puts $g.equal?(s)
puts $g.frozen?
puts attempt($g)

# an Array and a Hash value
s = +"ar"
a = [s.freeze]
puts a[0].equal?(s)
puts a[0].frozen?
puts attempt(a[0])
s = +"hs"
h = { k: s.freeze }
puts h[:k].equal?(s)
puts h[:k].frozen?
puts attempt(h[:k])

# a method's return
s = +"mr"
r = frozen_of(s)
puts r.equal?(s)
puts s.frozen?
puts attempt(r)
puts attempt(s)

# chains
s = +"ch"
puts s.freeze.equal?(s)
puts s.freeze.freeze.equal?(s)
t = +"ap"
u = (t << "x").freeze
puts u.equal?(t)
puts u
puts t.frozen?
puts attempt(t)

# the freeze of a frozen String is that String
lit = "lit".freeze
puts lit.equal?("lit".freeze)
puts lit.freeze.equal?(lit)
puts lit.frozen?
puts attempt(lit)
f = frozen_of(lit)
puts f.equal?(lit)
puts attempt(f)

# controls: the Strings that are not the receiver
s = +"dp"
d = s.dup.freeze
puts d.equal?(s)
puts d.frozen?
puts s.frozen?
puts attempt(s)
s = +"mi"
m = -s
puts m.equal?(s)
puts m.frozen?
puts s.frozen?
puts attempt(s)
p1 = +s
puts p1.equal?(s)
fz = "fz".freeze
puts (+fz).equal?(fz)
puts (+fz).frozen?
puts (-fz).equal?(fz)
