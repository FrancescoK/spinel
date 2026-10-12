# A chained push of values of different kinds into one Array widens its
# elements, as separate pushes do.

class Report
  def initialize = @vals = []

  def add(name, a)
    @vals << name << a.sum
    self
  end

  def vals = @vals
end

r = Report.new
r.add("x", [1, 2]).add("y", [3])
p r.vals

class Tally
  def initialize = @vals = []

  def add(name, a)
    @vals << a.sum << name
    self
  end

  def vals = @vals
end

t = Tally.new
t.add("x", [1, 2]).add("y", [3])
p t.vals

def local_chain(name, a)
  v = []
  v << name << a.sum
  v
end
p local_chain("z", [4, 5])

w = []
w << [5].sum << "w"
p w

u = []
u.push("a").push(1, :b)
p u

n = []
n << 1 << 2 << 3
p n
p n.sum

s = +"ab"
s << "c" << 100
p s
