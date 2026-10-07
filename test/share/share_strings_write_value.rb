# Flag-only: without the flag (as on master) each write's value is a copy
# and misses the change.
# A write in value position is the String its slot holds. When the rule
# makes that slot the shared handle, the write hands over the handle: into
# a box (a poly local, a poly Array or Hash, a `||=` on a poly local),
# into a slot that holds the handle (a local, an ivar, a global, a class
# variable, an ivar's or a local's `||=`, a multiple assignment's target),
# into a method's, a proc's or a block's parameter (an argument run ahead of
# the others, a default value included), and as a conditional's arm, for
# `=`, `||=` and `&&=` writes of a local, an ivar, a global and a class
# variable. A change through either name shows through the other.

# boxed
x = nil; x ||= (o1 = +"a"); o1 << "!"; p x
x2 = 1; x2 = (@i1 = +"b"); @i1 << "!"; p x2
a = [1]; a << ($g1 = +"c"); $g1 << "!"; p a
h = {1 => 2}; h[:k] = (o2 = +"d"); o2 << "!"; p h
o3 = ARGV[0]; x3 = 1; x3 = (o3 ||= +"e"); o3 << "!"; p x3
@i2 = +"f"; a2 = [1]; a2 << (@i2 &&= +"g"); @i2 << "!"; p a2
$g2 = nil; x4 = 1; x4 = ($g2 ||= +"h"); $g2 << "!"; p x4

# into a slot that holds the handle
o4 = ARGV[0]; y1 = (o4 ||= +"i"); o4 << "!"; p y1
o5 = +"s"; $y2 = (o5 &&= +"j"); o5 << "!"; p $y2
@y3 = (@i3 = +"k"); @i3 << "!"; p @y3
@y4 ||= (o6 = +"l"); o6 << "!"; p @y4
y5 = ARGV[0]; y5 ||= ($g3 = +"m"); $g3 << "!"; p y5

# an argument a method appends to
def app(v) = (v << "!"; v.size)
$g4 = nil; p app($g4 ||= +"t"); p $g4
@i4 = +"s"; p app(@i4 &&= +"u"); p @i4
p app(@i5 = +"v"); p @i5

# a proc's argument, a splatted one, a yielded one, a multiple
# assignment's value
l = ->(v) { v << "!" }
l.call(o8 = +"w"); p o8
l.call(*[(@i6 ||= +"x"), 1].first(1)); p @i6
def y1 = yield((@i7 = +"y"), 1)
y1 { |v, n| v << "!" }; p @i7
a3, b3 = (o9 = +"z"), 1; a3 << "!"; p o9

# an argument run ahead of the others: into a rest, a gather, beside
# keywords, a call that orders its operands
def gat(*r) = r[0] << "!"
gat(@i8 = +"a"); p @i8
def rst(a, *r) = r[0] << "!"
rst(1, $g5 = +"b"); p $g5
def kwa(v, k: 1) = v << "!"
kwa(@i9 = +"c", k: [1].size); p @i9
$n = 0
def nx = ($n += 1)
a4 = [1]; a4.push((@j1 = +"d"), nx); @j1 << "!"; p a4
def two(x, y) = x << y
two((@j2 = +"e"), "!" * nx); p @j2

# a conditional's arm, a parameter's default value
x5 = ARGV.empty? ? (@j3 = +"f") : nil; @j3 << "!"; p x5
x6 = ARGV.empty? && ($g6 ||= +"g"); $g6 << "!"; p x6
def dfl(v = (@j4 = +"h")) = v << "!"
dfl; p @j4

# an arm nested in parentheses and conditionals, an arm beside a raise
c7 = ARGV.empty?; d7 = !c7
t7 = +"q"; t7 << ""
t7 = c7 ? (c7 ? (d7 ? (@j5 = +"r") : (@j6 = +"s")) : (@j7 = +"u")) : +"n"; @j6 << "!"; p t7
t8 = +"q"; t8 << ""
t8 = c7 ? (c7 ? (d7 ? (x8 = 1; @j8 = +"r") : (x8 = 2; @j9 = +"s")) : +"u") : +"n"; @j9 << "?"; p t8
u8 = +"q"; u8 << ""; u8 = c7 ? (@k1 = +"k") : (raise "boom"); @k1 << "!"; p u8

# a String read of a local's `||=` is its String
o7 = ARGV[0]; p((o7 ||= +"n")); o7 << "!"; p o7

class K
  @@c = nil
  def self.run
    x = 1; x = (@@c ||= +"o"); @@c << "!"; p x
    @@d = +"s"; y = (@@d &&= +"p"); @@d << "!"; p y
    a = [1]; a << (@@e = +"q"); @@e << "!"; p a
    @@f = (t = +"r"); t << "!"; p @@f
    z = (@iv = +"s"); @iv << "!"; p z
  end
end
K.run

# an `&&=` that stores nothing leaves an unset class variable undefined
# (CRuby raises NameError reading it); an `||=` defines it either way
class K2
  def self.run
    begin
      x = (@@u &&= +"t")
    rescue NameError
    end
    p defined?(@@u)
    begin
      @@w &&= +"t"
      nil
    rescue NameError
    end
    p defined?(@@w)
    x = (@@u ||= +"u"); @@u << "!"; p x, defined?(@@u)
    @@w ||= +"w"; @@w ||= +"z"; y = @@w; y << "!"; p @@w, defined?(@@w)
  end
end
K2.run
