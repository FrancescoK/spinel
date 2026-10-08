# spinel: int64
# uniq, uniq! and the set operations of a mixed Array match elements as
# CRuby's do: small arrays by eql? alone, larger ones by hash, then eql?, the
# new or probing value asking. Each value kind below hashes the way it
# compares. Values eql? merges (0.0 and -0.0, a Complex with a -0.0 part, an
# Array or a Struct that holds itself and its unrolled copy) hash alike;
# values it keeps apart (Rational(1, 1) and 1, Complex(1, 0) and
# Complex(1.0, 0), Structs holding 1 and 1.0) stay apart on both paths. A
# class's own #hash runs once per element, and only where CRuby calls it; a
# class with eql? but no hash keeps its duplicates in a hashed uniq, as
# CRuby's identity hash does, and matches by its eql? in a small set
# operation. The large arrays take the table past its first size.
# spinel: gc-minor
require "ostruct"
S = Struct.new(:x, :y)
D = Data.define(:v)
$hashes = 0
class K
  attr_reader :v
  def initialize(v) = @v = v
  def hash
    $hashes += 1
    @v.hash
  end
  def eql?(o) = o.is_a?(K) && @v.eql?(o.v)
  def inspect = "K(#{@v.inspect})"
end
class EqlOnly
  attr_reader :v
  def initialize(v) = @v = v
  def eql?(o) = o.is_a?(EqlOnly) && @v == o.v
  def inspect = "E(#{@v})"
end
class EqOnly
  def ==(o) = true
  def inspect = "Q"
end
class Par
  def hash = 0
  def eql?(o) = o.is_a?(self.class)
  def inspect = self.class.name
end
class Kid < Par; end
class Ugly
  attr_reader :v
  def initialize(v) = @v = v
  def hash = object_id
  def eql?(o) = o.is_a?(Ugly) && @v == o.v
  def inspect = "U#{@v}"
end

p [1, 1.0, 2**70, 2**70, 1, -0.0, 0.0, 1.0, 0.0 / 0.0, 0.0 / 0.0, nil, true, false, nil, false].uniq
p [Rational(1, 1), 1, Rational(1, 2), 0.5, Rational(1, 2), Rational(2**70, 3), Rational(2**70, 3), 1.0].uniq
p [Complex(-0.0, 1), Complex(0.0, 1), Complex(1, 2), 1, Complex(1, 2)].uniq
p ["a", "a".b, :a, "a", "\xff".b, "\xff".dup.force_encoding("UTF-8"), :a, "b"].uniq
p [[1, 2], [1, 2.0], [1, 2], [[1], :a], [[1], :a], [], [], 1].uniq
p [{a: 1, b: 2}, {b: 2, a: 1}, {a: 1.0, b: 2}, {}, {}, {"k" => [1]}, {"k" => [1]}].uniq
p [(1..2), (1..2), (1...2), (0..0.0), (0..-0.0), (1.0..2.0), (1.0..2.0), ("a".."b"), ("a".."b")].uniq
p [S.new(1, "x"), S.new(1, "x"), S.new(1.0, "x"), D.new(3), D.new(3), D.new(3.0), Integer, Integer, String].uniq
p [OpenStruct.new(a: 1), OpenStruct.new(a: 1), OpenStruct.new(a: 1.0), 2].uniq.size
t = Process.times
p [t, t, 1].uniq.size
p [RuntimeError.new("x"), RuntimeError.new("x"), 1].uniq.size

a = [1]; a << a; b = [1]; b << b; c = [1, [1, a]]; d = [2, a]
p [a, b, c, d, 1].uniq.size, a.hash == c.hash, {a => 1}[c]
h = {k: 1}; h[:self] = h; g = {k: 1}; g[:self] = g
p [h, g, 1].uniq.size
p({Complex(-0.0, 1) => :found}[Complex(0.0, 1)])

$hashes = 0
ks = [K.new(1), K.new(2), K.new(1), K.new(1.0), K.new(2), 3]
p ks.uniq, $hashes
p [EqlOnly.new(1), EqlOnly.new(1), 1].uniq
p [EqOnly.new, 1, EqOnly.new, "x"].uniq.size

m = [3, "q", 3.0, nil, :s]
p m.uniq!, m
m = [1, "x", 1, :s, "x", 1.0]
p m.uniq!, m
fz = [1, "a", 1].freeze
begin
  fz.uniq!
rescue FrozenError => e
  p e.class
end

syms = %i[a b c d e f g]
x = (0...3000).map { |i| k = i % 1000; [k, k.to_s, k.to_f, syms[k % 5]][i % 4] }
y = (0...3000).map { |i| k = i % 700 + 500; [k, k.to_s, k.to_f, syms[k % 7]][i % 4] }
u = x.uniq
p u.size, u.first(5), u.last(3)
x2 = x.dup
p x2.uniq!.size, x2 == u
p (x | y).size, (x & y).size, (x - y).size, x.union(y).size, x.intersection(y).size, x.difference(y).size
p (x & y).first(5), (x - y).first(5), (x | y).last(5)
p x.intersect?(y), x.intersect?([:none, 0.5, "1000"])
p ([1, "a", 2.5, Rational(1, 1)] | [1.0, "a", Rational(1, 1), 1]), ([1, "a", 1.0] & [1.0, "a"]), ([1, 1.0, Rational(1, 1)] - [1])

$hashes = 0
ka = (0...40).map { |i| K.new(i % 7) }
kb = (0...30).map { |i| K.new(i % 5 + 4) }
p (ka | kb).size, $hashes
$hashes = 0
p (ka - kb).size, $hashes
$hashes = 0
p (ka & kb).size, $hashes

p [Complex(1, 0), 1, Complex(1.0, 0), Complex(1, 0)].uniq
p [Rational(2**70, 2**70), 1, Rational(1, 1), Rational(2**64, 1) - Rational(2**64 - 3, 1), Rational(3, 1)].uniq
p [S.new(K.new(1), 2), S.new(K.new(1), 2), S.new(1, 2), S.new(1.0, 2)].uniq.size
p [S.new(1, 2)] - [S.new(1.0, 2)], [S.new(1, 2)] & [S.new(1, 2)]
t = S.new(nil, 0); t.x = [t]; u = S.new(nil, 0); u.x = [S.new([t], 0)]
p t.hash == u.hash, [t, u].uniq.size, ([t] - [u]).size
p [Par.new, Kid.new].uniq, [Kid.new, Par.new].uniq
big = Array.new(20) { Par.new }
p (big - [Kid.new]).size, ([Kid.new] - big).size, (big & [Kid.new]).size, big.intersect?([Kid.new])
p [Ugly.new(1), 2] - [Ugly.new(1)], [Ugly.new(1), 2] & [Ugly.new(1)], [Ugly.new(1), 2] | [Ugly.new(1)], [Ugly.new(1), 2].intersect?([Ugly.new(1)])
p [Ugly.new(1), Ugly.new(1), 2].uniq.size
p ([EqlOnly.new(1), 2] - [EqlOnly.new(1)]).size, ([EqlOnly.new(1), 2] & [EqlOnly.new(1)]).size, ([EqlOnly.new(1), 2] | [EqlOnly.new(1)]).size, [EqlOnly.new(1), 2].intersect?([EqlOnly.new(1)])
def ks(n) = (0...n).map { |i| K.new(i) }
def calls; $hashes = 0; yield; $hashes; end
p [calls { ks(100) - ks(16) }, calls { ks(100) - ks(17) }, calls { ks(16) & ks(16) }, calls { ks(17) & ks(3) }]
p [calls { ks(8) | ks(8) }, calls { ks(9) | ks(8) }, calls { ks(16).intersect?(ks(16)) }, calls { ks(17).intersect?(ks(3)) }]
p [calls { ks(1).uniq }, calls { ks(1).uniq! }, calls { ks(2).uniq }]
