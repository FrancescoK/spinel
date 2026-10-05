# Marshal.dump writes a Hash subclass instance as CRuby does: `C` with its
# class, its pairs as a Hash's record, and its ivars after them under `I`
# (#7449). Each dump is printed, so the .expected (CRuby's own output) shows
# Spinel writes the bytes CRuby writes, which CRuby loads. Marshal.load reads
# them back as an instance of the class, from Spinel's dump or from one CRuby
# wrote (the literal below), whether the instance is typed as its class or
# boxed in a mixed Array, nested and shared.
class Options < Hash
  attr_accessor :tag
end

class Bag < Hash
end

o = Options[a: 1, "b" => [2]]
o.tag = "t"
s = Marshal.dump(o)
p s
q = Marshal.load(s)
p q.class, q, q.tag

x = [o, 1][ARGV.size]
p Marshal.dump(x) == s
two = Marshal.load(Marshal.dump([x, x, 3]))
p two[0].equal?(two[1]), two[1].class, two[1].tag, two[2]

p Marshal.dump(Bag[1, 2])
b = Marshal.load(Marshal.dump(Bag[1, 2]))
p b.class, b, b[1]

r = Marshal.load("\x04\bIC:\fOptions{\x06:\x06zi\x0E\x06:\t@tagI\"\x06w\x06:\x06EF".b)
p r.class, r, r.tag
