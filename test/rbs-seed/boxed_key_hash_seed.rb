# A Hash[String, Integer] signature declares the Ruby type, not the C
# form. A Hash whose String key came out of a box (`[s, 1][0]`) is one
# inference keys by boxed values, and no conversion makes it the
# String-keyed Hash the seed pinned: a seeded parameter, keyword, instance
# variable, attribute writer and Struct or Data member refused it ("given a
# Hash, which no conversion keeps in its sp_StrIntHash * slot"), and a
# seeded return emitted C that did not compile. Such a seed gives way, and
# the slot takes the form inference gives it, so each holds the caller's
# own Hash: a change through either name is seen through the other.
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
