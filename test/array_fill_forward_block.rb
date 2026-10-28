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

# a Proc argument that may be nil fills with the value when it is nil
def fv(a, pr) = a.fill(0, &pr)
p fv([1, 2], nil)
