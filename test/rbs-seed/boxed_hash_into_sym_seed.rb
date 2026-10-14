# A box handed to a parameter, keyword or return an --rbs signature types
# Hash[Symbol, untyped] holds a Hash of any kind: one read out of an Array of
# mixed values may have String keys, or keys of several classes. The seed
# used to unbox it into a Symbol-keyed copy, reading every key as a Symbol, so
# a String key came out as an empty Symbol and a lookup by it as nil. Such a
# seed gives way to a box as it does to a Hash with boxed keys: the slot takes
# the box, which is the caller's own Hash, and CRuby, which does not check
# signatures, gives the same answers.
# spinel: rbs-seed-check
class BhsTaker
  def take(h)
    h.keys
  end

  def take_kw(h:)
    h.size
  end

  def put(h)
    h[:z] = 1
    h
  end

  def give(v)
    v
  end
end

s = +"ab"
u = [s, 1][0]
x = [{ u => 5, "zz" => 6 }, 1][0]
t = BhsTaker.new
p t.take(x)
p t.take_kw(h: x)
r = t.put(x)
p r, r.equal?(x)
g = t.give(x)
g["new"] = 7
p x, g.equal?(x)
y = [{ k: 1 }, 1][0]
p t.take(y), t.give(y)
