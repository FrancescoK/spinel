# Flag-only: without the flag each name below holds its own copy.
# A variable that holds other values too (nil first, or an Integer on
# another path) is a box. When the rule shares its String, each String
# stored into it -- by `=`, `||=` or `&&=`, or as a conditional's arm -- is
# boxed as the shared handle, so a change through either name shows
# through the other: a local, an ivar (also a class method's), a global, a
# class variable and a constant (its `||=` too).
def app(v) = (v << "!"; v.size)
def p2(v, n) = v << "!" * n

x = nil; y = (x ||= +"x"); y << "!"; p x
z = nil; app(z ||= +"z"); p z
q = nil; p2(q ||= +"q", 3); p q

class K
  def self.run
    @o = nil; x = 1; x = (@o ||= +"o"); @o << "!"; p x
  end
end
K.run

class C
  @@x = +"c"
  def self.x = @@x
  def self.reset = (@@x = 1 if @@x.size > 99)
end
t = C.x; t << "1"; C.x << "2"; C.reset; p t, C.x

X = ARGV.size > 5 ? 1 : +"k"
def kx = X
u = kx; u << "1"; kx << "2"; p u, kx

$g = +"g"
def gx = $g
$g = 1 if ARGV.size > 5
w = gx; w << "1"; gx << "2"; p w, gx

$h = nil; v = ($h ||= +"h"); v << "!"; p $h
Y ||= +"y"; yw = Y; yw << "!"; p Y
