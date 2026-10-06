# Hash.new(&pr) makes the Proc or lambda the Hash's default proc, as a block
# literal is: a missing key answers what it answers, and it can store into
# the Hash. The block argument was ignored and every missing key read nil.
# A method's `&b` handed on (`def mk(&b) = Hash.new(&b)`) gives its caller's
# block, or no default proc when the caller passes none.
pr = proc { |h, k| h[k] = k.to_s * 2 }
h = Hash.new(&pr)
p h[:ab], h
twice = proc { |_h, k| k * 2 }
t = Hash.new(&twice)
p t[3], t
lists = Hash.new(&proc { |_h, _k| [] })
lists[:a] << 1
p lists, lists[:b]
s = Hash.new(&->(_h, k) { k.to_s })
p s["x"], s.fetch("y", 0)
def mk(&b) = Hash.new(&b)
p mk { |_h, k| k.to_s }[:z], mk[:z], mk.size
def fill(&b)
  x = Hash.new(&b)
  x
end
f = fill { |hh, k| hh[k] = k * 2 }
p f[2], f
g = fill { |hh, k| hh.size + k }
p g[2], g[3]
class C
  def initialize(&b)
    @h = Hash.new(&b)
  end
  def get(k) = @h[k]
end
p C.new { |_h, k| k.to_s * 3 }.get(:a)
