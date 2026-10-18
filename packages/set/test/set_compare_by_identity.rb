# Set#compare_by_identity: the Set finds its members by equal?, as CRuby 4.0's
# does. Two instances whose eql? and hash agree are two members; a copy and
# the operators built on one (|, -, ^) compare the same way, the others (&,
# map!, flatten, classify) answer a plain Set.
require "set"

class K
  attr_reader :n
  def initialize(n) = @n = n
  def hash = @n.hash
  def eql?(o) = o.is_a?(K) && o.n == @n
  def inspect = "K#{@n}"
end

a = K.new(1)
b = K.new(1)
p Set[a, b].size, Set[a].compare_by_identity?

t = Set.new.compare_by_identity
p t.compare_by_identity?, t.equal?(t.compare_by_identity)
t << a << b << a
p t.size, t.include?(a), t.include?(K.new(1)), t.member?(b), t === a
p t.add?(a).nil?, t.add?(K.new(2)).size
t.delete(K.new(2))
p t.size
p t.delete?(K.new(1)).inspect
p t.to_a.size, t.inspect

def ident(a, b) = Set.new.compare_by_identity << a << b

later = Set[a, K.new(2)]
later.compare_by_identity
later << b
p later.size, later.include?(K.new(2))

d = ident(a, b).dup
p d.compare_by_identity?, d.size, ident(a, b).clone.compare_by_identity?

t = ident(a, b)
p (t | Set[K.new(1)]).compare_by_identity?, (t | Set[K.new(1)]).size
p (t - Set[a]).compare_by_identity?, (t - Set[a]).size, (t - [K.new(1)]).size
p (t ^ Set[a]).compare_by_identity?, (t ^ Set[a]).inspect, (t ^ [K.new(3)]).size
p (t & Set[a]).compare_by_identity?, (t & Set[a]).size, (Set[a] & t).size
p (t & Set[K.new(1), K.new(5), K.new(6)]).size
p (t & [b]).inspect

p Set.new(t).compare_by_identity?, Set.new(t).size
p t.subset?(Set[a]), Set[a].superset?(t), Set[b] <= t, Set[a] <= t
p t <=> Set[a], Set[a] <=> t, t <=> ident(a, b), t <=> ident(a, K.new(1))
p t == ident(a, b), t == Set[a, b], t.eql?(ident(b, a)), Set[].compare_by_identity == Set[]
p t.disjoint?([K.new(1)]), t.intersect?([a]), t.intersect?(Set[K.new(1)]),
  Set[K.new(1), K.new(7), K.new(8)].intersect?(t)

m = ident(a, b)
m.map! { |x| x }
p m.compare_by_identity?, m.size
s = ident(a, b)
p s.select! { true }.inspect, s.compare_by_identity?
r = ident(a, b)
r.replace([K.new(1), K.new(1)])
p r.compare_by_identity?, r.size
r.replace(Set[a])
p r.compare_by_identity?
c = ident(a, b)
c.clear
p c.compare_by_identity?, c.size
x = ident(a, b)
x.subtract([K.new(1)])
p x.size
x.subtract([b])
p x.size
y = ident(a, b)
p y.merge([K.new(1), a]).size
k = ident(a, b)
k.keep_if { true }
k.delete_if { false }
p k.compare_by_identity?, k.size
p ident(a, b).classify { 1 }.values.first.compare_by_identity?
p ident(a, b).divide { 1 }.first.compare_by_identity?
p ident(a, b).flatten.compare_by_identity?, ident(a, b).flatten.size
f = Set[Set[a], b].compare_by_identity
f.flatten!
p f.compare_by_identity?, f.size

p Set.new([:t, :s, nil, true]).compare_by_identity.include?(:s)
begin
  Set[:a].freeze.compare_by_identity
rescue FrozenError => e
  p e.class
end
p Set[:a].freeze.compare_by_identity?
