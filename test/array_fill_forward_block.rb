# A block forwarded to Array#fill (`a.fill(v, &b)`) fills from the block
# when the caller gives one, and from the value when it does not.

def pf(a, v, &b) = a.fill(v, &b)
p pf([1, 2], 0)
p pf([1, 2], nil) { |i| i + 9 }

def a2(a, &b) = a.fill(0, 1, &b)
p a2([1, 2, 3]) { |i| i + 10 }

def a3(a, &b) = a.fill(1..2, &b)
p a3([1, 2, 3]) { |i| i * 100 }

def a4(a, &b) = a.fill(&b)
p a4([1, 2]) { |i| i - 5 }

pr = proc { |i| "s#{i}" }
p [1, 2].fill(0, &pr)
p [1, 2].fill(&pr)

class V < Array
  def fill_all(v, &b) = fill(v, &b)
end
p V.new([1, 2]).fill_all(0)
p V.new([1, 2]).fill_all(nil) { |i| i + 9 }

def anon(a, &) = a.fill(1, &)
p anon([4, 5, 6]) { |i| -i }
p anon([4, 5, 6])

def ff(a, &b) = a.fill(0, &b)
p ff([1.5, 2.5]) { |i| i * 0.5 }
p ff([1.5, 2.5])

def fs(a, &b) = a.fill(0, &b)
p fs(%w[a b]) { |i| "x#{i}" }

# a receiver whose callers pass Arrays of more than one kind
def fp(a, &b) = a.fill(0, &b)
p fp([1.5, 2.5]) { |i| i * 0.5 }
p fp([1, 2]) { |i| i * 3 }
p fp([1, 2])
def fp2(a, &b) = a.fill(1, 1, &b)
p fp2([1.5, 2.5, 3.5]) { |i| i * 0.25 }
p fp2([1, 2, 3]) { |i| -i }
def fp3(a, &) = a.fill(&)
p fp3([1.5, 2.5]) { |i| i + 0.5 }
p fp3([:a, :b]) { |i| i }

# a block value whose kind is decided at run time
xs = [1, "a", nil]
p [7, 8, 9].fill { |i| i == 1 ? 5 : xs[i == 0 ? 0 : 2] }

# a block whose value comes from `next` on some indexes, read once
$calls = 0
def side(i) = ($calls += 1; i.even? ? i : nil)
p [1, 2, 3, 4].fill { |i| next 7 if i == 1; side(i) }
p $calls
p a4([1, 2, 3, 4]) { |i| next 7 if i == 1; side(i) }
p $calls

# a Proc argument that may be nil fills with the value when it is nil,
# and runs the Proc when it holds one
def fv(a, pr) = a.fill(0, &pr)
p fv([1, 2], nil)
p fv([1, 2], proc { |i| i + 5 })
class FillHolder
  def initialize(pr) = @pr = pr
  def go(a) = a.fill(1, 1, &@pr)
end
p FillHolder.new(nil).go([1, 2, 3])
p FillHolder.new(->(i) { i * 10 }).go([1, 2, 3])
$args = 0
def fill_start = ($args += 1; 0)
def fa(a, pr) = a.fill(fill_start, &pr)
p fa([1, 2], nil), fa([1, 2], proc { |i| i * 2 }), $args

# the Proc argument is read once, after the receiver and the arguments
def fd(a, pr = nil) = a.fill(0, &pr)
p fd([1, 2]), fd([1, 2], proc { |i| i + 1 })
def fm(n) = n > 0 ? proc { |i| i + n } : nil
def fe(a, n) = a.fill(0, &fm(n))
p fe([1, 2], 1), fe([1, 2], 0)
def fs(a)
  pr = nil
  pr = proc { |i| pr = proc { |j| j * 100 }; i + 1 }
  a.fill(0, &pr)
end
p fs([1, 2, 3])
fa2 = [1, 2]
fpr = proc { |i| i + 1 }
fa2.fill((fpr = nil; 0), &fpr)
p fa2
# a lambda run by an argument may change pr; a constant is read after the arguments
def fcl(a)
  pr = proc { |i| i + 1 }
  clr = -> { pr = nil; 0 }
  a.fill(clr.(), &pr)
end
p fcl([1, 2])
FILL_PRC = proc { |i| i + 7 }
def fq(a) = a.fill(0, &FILL_PRC)
p fq([1, 2])
class FillBump
  def initialize(pr) = @pr = pr
  def bump = (@pr = nil; 0)
  def go(a) = a.fill(bump, &@pr)
end
p FillBump.new(proc { |i| i + 3 }).go([1, 2])
