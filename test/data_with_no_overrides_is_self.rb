# Data#with with no overrides answers the receiver itself; with one it answers a
# new instance of the same class.
P = Data.define(:x, :y)
a = P.new(1, 2)
b = a.with
p [b.equal?(a), b]
c = a.with(x: 5)
p [c.equal?(a), c, a]
p a.with.with.equal?(a)
p a.with(x: 1).equal?(a)

D = Data.define(:name, :tags)
d = D.new("n", [1, 2])
p d.with.equal?(d)
p d.with.tags.equal?(d.tags)

log = []
r = (log << :recv; a).with
p [r.equal?(a), log]

class Q
  def initialize = @pt = P.new(3, 4)
  def pt = @pt
end
q = Q.new
p q.pt.with.equal?(q.pt)
p [a.with.equal?(a), b.with.equal?(b), c.with.equal?(c)]
