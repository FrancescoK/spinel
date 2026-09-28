# A `for` index can be any assignment target, not only a local: a global,
# an instance or class variable, a constant, an attribute, an index, or a
# list of any of these. The loop variable keeps the last value the loop
# bound, and a block made in the body reads the one variable the loop shares.

for $f in 1..3; end
p $f

for @i in [4, 5]; end
p @i

class Box
  attr_accessor :v
  @@c = 0
  def self.count
    for @@c in 1..4; end
    @@c
  end

  def run
    for @x in [1.5, 2.5]; end
    procs = []
    for @y in 1..3
      procs << -> { @y }
    end
    p @x, procs.map(&:call)
  end
end
p Box.count
Box.new.run

for LAST in [1]; end
p LAST

o = Box.new
for o.v in [7, 8]; end
p o.v

a = [0, 0]
for a[0] in [9, 10]; end
p a
h = {}
for h[:k] in %w[x y]; end
p h

for $g, @h in [[1, 2], [3, 4]]; end
p $g, @h
for x, $y in [[1, 2], [3]]; end
p x, $y
for $k, $w in {1 => "one", 2 => "two"}; end
p $k, $w
for $z, o.v in [[1, :s], [2, :t]]; end
p o.v, $z
for m, *n in [[1, 2, 3], [4, 5, 6]]; end
p m, n
for q, (r, s) in [[3, [1, 2]]]; end
p q, r, s

for $s in ["a", "b"]
  break if $s == "a"
end
p $s
for $u in []; end
p $u

class Pairs
  include Enumerable
  def each
    yield 1, 2
    yield 3, 4
  end
end
for $e1, $e2 in Pairs.new; end
p $e1, $e2
for $e3 in Pairs.new; end
p $e3

for i in 1..3; end
p i
for j in 1..5
  break if j == 2
end
p j
for k in 1...4; end
p k

fs = []
for t in 1..3
  fs << -> { t }
end
p fs.map(&:call)
gs = []
for w in %w[a b c]
  gs << -> { w }
end
p gs.map(&:call)
bs = []
for $q in [10, 20]
  bs << proc { $q }
end
p bs.map(&:call)
