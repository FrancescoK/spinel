# Marshal.dump writes an Array subclass instance as CRuby does: `C` with its
# class, its elements as an Array's, and its ivars after them under `I`
# (#7449). Each dump is printed, so the .expected (CRuby's own output) shows
# Spinel writes the bytes CRuby writes, which CRuby loads. Marshal.load reads
# them back as an instance of the class, from Spinel's dump or from one CRuby
# wrote (the literals below), whether the instance is typed as its class,
# boxed in a mixed Array, nested and shared, or of an Array kind of its own.
class Page < Array
  attr_accessor :source
end

class Nums < Array
  def total = sum
end

pg = Page[1, "a"]
pg.source = "room"
s = Marshal.dump(pg)
p s
q = Marshal.load(s)
p q.class, q, q.source

x = [pg, "s"][ARGV.size]
p Marshal.dump(x) == s
both = Marshal.load(Marshal.dump([x, x, 2]))
p both[0].equal?(both[1]), both[0].class, both[1].source, both[2]

n = Nums[1, 2, 3]
p Marshal.dump(n)
m = Marshal.load(Marshal.dump(n))
p m.class, m.total, m.size

r = Marshal.load("\x04\bIC:\tPage[\ai\x06I\"\x06b\x06:\x06EF\x06:\f@sourceI\"\thall\x06;\x06F".b)
p r.class, r, r.source
p Marshal.load("\x04\bC:\tNums[\bi\x06i\ai\b".b).total
