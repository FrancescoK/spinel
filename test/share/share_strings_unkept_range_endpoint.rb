# spinel: gc-stress
# A Range keeps the String objects its endpoints were made from. A method
# that puts its parameter into a Range, keeps the Range, and answers the
# parameter too answers a String the Range holds: the endpoint is a flow into
# the Range's elements, so the parameter is taken as kept. Each check keeps
# the answer in one name, changes the endpoint through the Range, and reads
# both (CRuby: the one String).
$r = nil
class Box
  attr_reader :a
  def put(a) = @a = a
end
def lo(s)
  $r = (s.."z")
  s
end
def lo_excl(s)
  $r = (s..."z")
  s
end
def hi(s)
  $r = ("a"..s)
  s
end
def both(s)
  $r = Range.new(s, s)
  s
end
def new_lo(s)
  $r = Range.new(s, "z")
  s
end
def endless(s)
  $r = (s..)
  s
end
def beginless(s)
  $r = (..s)
  s
end
def clamped(s)
  $r = (+"m").clamp(s..s)
  s
end
class Keeper
  def initialize(s) = @r = (s.."z")
  def lo = @r.begin
end
def held(s)
  k = Keeper.new(s)
  $r = k.lo
  s
end
def covers(s)
  (s.."z").cover?("d")
  s
end
b = Box.new; b.put(lo(+"a")); $r.begin << "!"; p [b.a, b.a.equal?($r.begin)]
b = Box.new; b.put(lo_excl(+"b")); $r.begin << "!"; p [b.a, b.a.equal?($r.begin)]
b = Box.new; b.put(hi(+"c")); $r.end << "!"; p [b.a, b.a.equal?($r.end)]
b = Box.new; b.put(both(+"d")); $r.begin << "!"; p [b.a, b.a.equal?($r.end)]
b = Box.new; b.put(new_lo(+"e")); $r.begin << "!"; p [b.a, b.a.equal?($r.begin)]
b = Box.new; b.put(endless(+"f")); $r.begin << "!"; p [b.a, b.a.equal?($r.begin)]
b = Box.new; b.put(beginless(+"g")); $r.end << "!"; p [b.a, b.a.equal?($r.end)]
b = Box.new; b.put(clamped(+"h")); $r << "!"; p [b.a, b.a.equal?($r)]
b = Box.new; b.put(held(+"i")); $r << "!"; p [b.a, b.a.equal?($r)]
# the Range only reads the String: nothing keeps it
$r = +"o"
b = Box.new; b.put(covers(+"j")); $r << "!"; p [b.a, b.a.equal?($r)]
