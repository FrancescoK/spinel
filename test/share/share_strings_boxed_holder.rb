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

# A conditional value stored into such a holder: a String-typed one (every
# arm a String) is boxed whole, a mixed one (an Integer, nil or another
# class on some arm) box by box, so each String arm is the shared handle. An
# `if` or ternary, `case`/`when`, `case`/`in`, `begin` (its `rescue`s, its
# `else`, which replaces the body's value, and an `ensure`, which adds none),
# a modifier `rescue`, and one of these inside another.
def bang(v) = (v << "!" if v.is_a?(String); v)
n = ARGV.size

a1 = nil; b1 = (a1 ||= (n == 0 ? +"a" : +"b")); b1 << "!"; p a1
a2 = nil; b2 = (a2 ||= (n == 0 ? +"a" : 1)); bang(b2); p a2
a3 = nil; b3 = (a3 ||= (n != 0 ? 1 : +"a")); bang(b3); p a3
a4 = nil; b4 = (a4 ||= case n when 0 then +"a" else +"b" end); b4 << "!"; p a4
a5 = nil; b5 = (a5 ||= case n when 0 then +"a" else 1 end); bang(b5); p a5
a6 = nil; b6 = (a6 ||= case n when 1 then 1 when 0 then +"a" end); bang(b6); p a6
a7 = nil; b7 = (a7 ||= case [n]; in [Integer] then +"a"; else 1 end); bang(b7); p a7
a8 = nil; b8 = (a8 ||= case n; in 1 then 1; in 0 then +"a" end); bang(b8); p a8
a9 = nil; b9 = (a9 ||= begin; +"a"; rescue; +"b"; end); b9 << "!"; p a9
c1 = nil; d1 = (c1 ||= begin; Integer("zz"); rescue; +"a"; end); bang(d1); p c1
c2 = nil; d2 = (c2 ||= begin; 1; rescue; +"a"; else; +"b"; ensure; 3; end); bang(d2); p c2
c3 = nil; d3 = (c3 ||= begin; Integer("zz"); rescue; +"a"; else; 2; end); bang(d3); p c3
c4 = nil; d4 = (c4 ||= (Integer("zz") rescue +"a")); bang(d4); p c4
c5 = nil; d5 = (c5 ||= (n == 0 ? (n == 0 ? +"a" : 1) : case n when 1 then 2 else +"b" end)); bang(d5); p c5
c6 = nil; d6 = (c6 ||= (n == 0 ? begin; Integer("zz"); rescue; +"a"; end : 1)); bang(d6); p c6

e1 = nil; f1 = (e1 = (n == 0 ? +"a" : 1)); bang(f1); p e1
e2 = nil; f2 = (e2 = case n when 0 then +"a" else 1 end); bang(f2); p e2
e3 = nil; f3 = (e3 = begin; Integer("zz"); rescue; +"a"; end); bang(f3); p e3

class K
  def self.cond(n)
    @o = 1
    a = (@o = (n == 0 ? +"a" : +"b")); a << "!"
    b = (@o = case n when 0 then +"b" else 1 end); bang(b)
    c = (@o = begin; Integer("zz"); rescue; +"c"; end); bang(c)
    [a, b, c, @o]
  end
end
p K.cond(n)

$g = 1; $g = (n == 0 ? +"a" : +"b"); gv = $g; gv << "!"; p $g
$h = nil; h1 = ($h = case n; in 0 then +"a"; else 1 end); bang(h1); p $h
Z = 1 if n > 5
Z = (n == 0 ? +"a" : +"b"); zv = Z; zv << "!"; p Z
