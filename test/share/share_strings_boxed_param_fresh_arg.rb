# spinel: share
# spinel: gc-minor
# A fresh String handed to a parameter that also takes other values (nil, an
# Integer) reaches a box. When the rule shares that parameter's String with
# the instance variable and the names that read it, the box holds the
# handle, so a change through one name shows through the others.
class K
  def initialize(s) = @s = s
  def kget = @s
end
k = K.new(+"abc")
a = k.kget
a << "!"
p k.kget, a
K.new(nil)

# a default value, a frozen literal and a concatenation
class D
  def initialize(s = +"dflt") = @s = s
  def dget = @s
end
d = D.new
e = d.dget
e << "1"
p d.dget
l = D.new("lit")
f = l.dget
p f.frozen?
begin
  f << "!"
rescue FrozenError => ex
  puts ex.message
end
class DL
  def initialize(s = "dlit") = @s = s
  def lget = @s
end
dl = DL.new.lget
p dl.frozen?
DL.new(nil)
g = D.new(+"ab" + "cd")
h = g.dget
h << "!"
p g.dget
D.new(3)

# a method that keeps its parameter and answers it
def keep(s)
  $kept = s
  s
end
x = keep(+"str")
x << "?"
p $kept, x
keep(1)

# two parameters, one of them a box
class Pair
  def initialize(a, b)
    @a = a
    @b = b
  end
  attr_reader :a, :b
end
pr = Pair.new(+"l", +"r")
pr.a << "1"
pr.b << "2"
p pr.a, pr.b
Pair.new(nil, 5)

# a literal is frozen and static: every site of it stays the one object
class Same
  def initialize(a, b)
    @a = a
    @b = b
  end
  def same = @a.equal?(@b)
end
p Same.new("lit", "lit").same
Same.new(nil, 1)

# a call through a Method object is a call of the method
class Setter
  def initialize(s) = @s = s
  def set(v) = (@s = v)
  def sget = @s
end
st = Setter.new(+"abc")
Setter.new(nil)
st.set(5)
sm = st.method(:set)
sm.call(+"ghi")
s1 = st.sget
s1 << "!"
p st.sget
sm.(+"jkl")
s2 = st.sget
s2 << "?"
p st.sget
sm[+"mno"]
s3 = st.sget
s3 << "#"
p st.sget
Setter.instance_method(:set).bind(st).call(+"pqr")
s4 = st.sget
s4 << "%"
p st.sget

# a constructor called on the class its method runs for
class Maker
  def initialize(s) = @s = s
  def mget = @s
  def self.mk = new(+"mk")
  def self.mk2 = self.new(+"mk2")
  def twin = self.class.new(+"tw")
end
Maker.new(nil)
m1 = Maker.mk.mget
m1 << "1"
m2 = Maker.mk2
m3 = m2.mget
m3 << "2"
p m2.mget
m4 = Maker.new(+"zz").twin
m5 = m4.mget
m5 << "3"
p m4.mget

# a call result is the argument: the handle its method publishes is the box's
def idf(y) = y
class Wrap
  def initialize(s) = @s = s
  def wget = @s
end
Wrap.new(nil)
wv = +"abc"
wk = Wrap.new(idf(wv))
wk.wget << "!"
p wv, wk.wget
ww = +"def"
wk2 = Wrap.new(ww.itself)
wk2.wget << "?"
p ww, wk2.wget

# a Method object's other ways to be called
class Meth
  def initialize(s) = @s = s
  def mget = @s
  def mset(v) = (@s = v)
end
Meth.new(nil)
me = Meth.new(5)
mp = me.method(:mset).to_proc
mp.call(+"proc")
me1 = me.mget
me1 << "#"
p me.mget
Meth.instance_method(:mset).bind_call(me, +"bc")
me2 = me.mget
me2 << "*"
p me.mget
mc = me.method(:mset).curry
mc.(+"cur")
me3 = me.mget
me3 << "!"
p me.mget
def call_with(m, v) = m.call(v)
call_with(me.method(:mset), +"arg")
me4 = me.mget
me4 << "?"
p me.mget

# a constructor on the class its method runs for: a subclass, a parameter
class Base
  def initialize(s) = @s = s
  def bget = @s
  def twin = self.class.new(+"tw")
  def self.mk1(v) = Base.new(v)
  def self.mk2(v) = self.new(v)
  def self.mk3(v) = new(v)
  def tw(v) = self.class.new(v)
end
class Sub < Base
end
Base.new(nil)
bz = Sub.new(+"q").twin
bz1 = bz.bget
bz1 << "#"
p bz.bget, bz.class
by = Base.mk1(+"a1")
by1 = by.bget
by1 << "?"
p by.bget
by = Base.mk2(+"a2")
by1 = by.bget
by1 << "?"
p by.bget
by = Base.mk3(+"a3")
by1 = by.bget
by1 << "?"
p by.bget
by = Base.new(+"q").tw(+"a4")
by1 = by.bget
by1 << "?"
p by.bget

# a call result beside a default that runs code: hoisted ahead of the call
def dflt = +"d"
class Opt
  def initialize(s, t = dflt) = @s = s
  def oget = @s
end
Opt.new(nil)
ov = +"abc"
ok = Opt.new(idf(ov))
ok.oget << "!"
p ov, ok.oget
class Opt2
  def initialize(s, t = $stdout.sync) = @s = s
  def oget2 = @s
end
Opt2.new(nil, 1)
ov2 = +"xyz"
ok2 = Opt2.new(idf(ov2), [].size)
ok2.oget2 << "?"
p ov2, ok2.oget2

# a Proc built from a literal block holds no method
lam = ->(v) { v }
lam.call(+"lit")
cl = lam.curry
cl.(+"cur")
