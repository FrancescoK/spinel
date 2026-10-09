# String#clamp can answer a bound read from a box. A box holding a plain
# String hands on that String itself, so a mutation through the answer
# shows in the box's variable.
def pick(i, s)
  i > 0 ? s : 5
end
pick(0, {a: 1})
class Holder
  def initialize(v) = @v = v
  def grow(s)
    r = s.clamp("a", @v)
    r << "!"
    p [@v, r.equal?(@v)]
  end
end
s = +"zz"
hi = pick(ARGV.size + 1, "c" * 2)
r = s.clamp("a", hi)
p r.equal?(hi)
r << "!"
p hi
lo = pick(ARGV.size + 1, "x" * 2)
r2 = (+"b").clamp(lo, "z")
r2 << "?"
p [lo, r2.equal?(lo)]
Holder.new(pick(ARGV.size + 1, "d" * 2)).grow(+"zz")
r4 = s.clamp("a", pick(ARGV.size + 1, "e" * 2))
r4 << "%"
p r4
r5 = (+"m").clamp("a", hi)
r5 << "&"
p [r5, hi]
