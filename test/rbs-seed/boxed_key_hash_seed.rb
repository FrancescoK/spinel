# A Hash[String, Integer] signature declares the Ruby type, not the C
# form. A Hash whose String key came out of a box (`[s, 1][0]`) is one
# inference keys by boxed values, and no conversion makes it the
# String-keyed Hash the seed pinned: a seeded parameter, keyword, instance
# variable, attribute writer and Struct or Data member refused it ("given a
# Hash, which no conversion keeps in its sp_StrIntHash * slot"), and a
# seeded return emitted C that did not compile. Such a seed gives way, and
# the slot takes the form inference gives it, so each holds the caller's
# own Hash: a change through either name is seen through the other. A
# Hash[Symbol, untyped] parameter and a return typed Hash[String, untyped]
# or Hash[Symbol, untyped] converted such a Hash into a copy instead, so the
# change was lost, and the parameter raised TypeError on a key that is not a
# Symbol, where CRuby, which does not check signatures, takes it. An
# instance variable seeded Hash[Symbol, untyped] that such a parameter (seeded
# the same way, or not seeded at all) is stored into gives way too: it took
# the box into a Symbol-keyed copy whose keys were not the Hash's.
# spinel: rbs-seed-check
class BkhTaker
  def take(h)
    h["p"] = 1
    h
  end

  def take_kw(h:)
    h["k"] = 2
    h
  end
end

class BkhHolder
  attr_writer :w

  def initialize(v)
    @x = v
  end

  def x = @x
  def w = @w
end

class BkhBox
  def initialize(s)
    @s = s
  end

  def get
    { @s => 1 }
  end
end

class BkhSymTaker
  def take(h)
    h[:z] = 1
    h
  end
end

class BkhKeep
  def initialize(k)
    @h = { k => 1 }
  end

  def h = @h
  def g = @h
end

class BkhSymHold
  def initialize(o)
    @o = o
  end

  def keys = @o.keys
  def get(k) = @o[k]
end

class BkhSymIvar
  def initialize(o)
    @o = o
  end

  def o = @o
end

BkhPoint = Struct.new(:x)
BkhData = Data.define(:x)

s = +"ab"
s << "1"
u = [s, 1][0]

a = { u => 1 }
r = BkhTaker.new.take(a)
p r, r.equal?(a), a

b = { u => 1 }
r = BkhTaker.new.take_kw(h: b)
p r, r.equal?(b)

c = { u => 1 }
o = BkhHolder.new(c)
c["i"] = 3
p o.x, o.x.equal?(c)

d = { u => 1 }
o.w = d
d["j"] = 4
p o.w, o.w.equal?(d)

g = BkhBox.new(u).get
s << "2"
p s, g, g.keys[0].frozen?

e = { u => 1 }
pt = BkhPoint.new(e)
e["s"] = 5
p pt.x, pt.x.equal?(e)

f = { u => 1 }
dt = BkhData.new(x: f)
f["d"] = 6
p dt.x, dt.x.equal?(f)

y = [:k, 1][0]
h = { y => 2 }
r = BkhSymTaker.new.take(h)
p h, r.equal?(h)
h = { u => 3 }
r = BkhSymTaker.new.take(h)
p h, r.equal?(h)

ks = BkhKeep.new(u)
ks.h["x"] = 2
p ks.h
ky = BkhKeep.new(y)
ky.g[:w] = 3
p ky.g, ky.g.equal?(ky.h)

sh = BkhSymHold.new({ u => 5, "zz" => 6 })
p sh.keys, sh.get("zz")
sy = BkhSymHold.new({ k: 6 })
p sy.keys, sy.get(:k)

hh = { u => 7 }
si = BkhSymIvar.new(hh)
si.o["q"] = 8
p hh, si.o.equal?(hh)
