# String#clamp answers its receiver, its min or its max object itself
# (Comparable#clamp), whether or not anything changes the String it
# answers: equal? and object_id see that operand. Bounds given as two
# arguments, as a Range literal or a Range held in a variable, open on one
# side with nil, read from parameters, ivars and globals, frozen literals
# and allocating operands.

s = +"m"; lo = +"a"; hi = +"z"
c = s.clamp(lo, hi)
p [c.equal?(s), c.equal?(lo), c.equal?(hi)]
s = +"z"; lo = +"a"; hi = +"n"
c = s.clamp(lo, hi)
p [c.equal?(s), c.equal?(lo), c.equal?(hi)]
s = +"a"; lo = +"b"; hi = +"n"
c = s.clamp(lo, hi)
p [c.equal?(s), c.equal?(lo), c.equal?(hi)]
p c.object_id == lo.object_id

lo = +"b"; hi = +"y"
p "a".clamp(lo, hi).equal?(lo)
p "a".clamp(lo..hi).equal?(lo)
p "z".clamp(lo..hi).equal?(hi)
s = +"m"
p s.clamp(lo..hi).equal?(s)
p s.clamp("b".."y").equal?(s)
r = lo..hi
p ["a".clamp(r).equal?(lo), "z".clamp(r).equal?(hi), s.clamp(r).equal?(s)]

# nil leaves a side open
s = +"a"
p [s.clamp(lo, nil).equal?(lo), s.clamp(nil, lo).equal?(s)]

# a frozen operand is answered frozen
flo = "b"
c = "a".clamp(flo, "y")
p [c.equal?(flo), c.frozen?]
begin
  c << "!"
rescue FrozenError => e
  p e.class
end

# through a method, from parameters
def pick(s, lo, hi) = s.clamp(lo, hi)
s = +"m"
p [pick(s, lo, hi).equal?(s), pick("a", lo, hi).equal?(lo), pick("z", lo, hi).equal?(hi)]

# from ivars and globals
class ClampBounds
  attr_reader :lo, :hi
  def initialize
    @lo = +"b"
    @hi = +"y"
  end
  def pick(s) = s.clamp(@lo, @hi)
end
k = ClampBounds.new
p [k.pick("a").equal?(k.lo), k.pick("z").equal?(k.hi)]
$clamp_lo = +"b"
$clamp_hi = +"y"
p ["a".clamp($clamp_lo, $clamp_hi).equal?($clamp_lo), "z".clamp($clamp_lo, $clamp_hi).equal?($clamp_hi)]

# answers kept in containers, and a chain of clamps
a = ["a".clamp(lo, hi), "z".clamp(lo, hi)]
p [a[0].equal?(lo), a[1].equal?(hi)]
h = {k: "a".clamp(lo, hi)}
p h[:k].equal?(lo)
s = +"a"
p s.clamp(lo, hi).clamp(lo, hi).equal?(lo)
p ["a", "m", "z"].map { |x| x.clamp(lo, hi) }.map { |x| x.equal?(lo) || x.equal?(hi) }

# allocating operands are held across the ones after them
n = ARGV.size
p ("m#{n}").clamp("a#{n}", "z#{n}")
p ("a#{n}").clamp("b#{n}", "z#{n}")
p ("m#{n}").clamp(("a#{n}".."z#{n}"))
bl = "b#{n}"
p "a".clamp(bl, "z#{n}").equal?(bl)
