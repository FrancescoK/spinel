# spinel: share
# spinel: gc-minor
# An Array of shared Strings a method answers is held as their handles: the
# caller's name is the callee's Array, and a change through either shows
# through the other.
def make(s)
  a = [s, +"y"]
  s << "m"
  a
end
t = +"t"
r = make(t)
r << +"z"
r[0] << "!"
r.each { |x| x << "." }
p r, t, r[0].equal?(t)
q = make(t)
q2 = q
q2 << +"w"
p q.size, q

# the parameter itself, and one of two
def id(a) = a
def pick(a, b, first) = first ? a : b
x = [t, +"x"]
y = [+"y"]
r = id(x)
r << +"r"
r[0] << "?"
p x, t, r.size
z = pick(x, y, true)
z << +"z"
p x.size, y.size
z = pick(x, y, false)
z << +"zz"
p x.size, y.size

# returns in branches, and the value asked in a condition
def two(first)
  t = +"t"
  a = [t]
  b = [+"b"]
  t << "!"
  return a if first
  b
end
u = two(true)
v = two(false)
u << +"u"
v << +"v"
p u, v, two(true).empty?
p u.size, two(false).first

# kept in an instance variable and answered
class Keep
  def keep(a)
    @a = a
    a
  end
  def again = @a
  def bang = @a.each { |s| s << "k" }
end
k = Keep.new
rows = [t]
kept = k.keep(rows)
k.bang
kept << +"r"
k.again << +"s"
p rows, t

# built over and over
def row(i)
  s = +"row"
  l = [s]
  s << i.to_s
  l
end
all = []
200.times do |i|
  l = row(i)
  l << +"extra" if i % 4 == 0
  all << l.size
  GC.start if i % 50 == 0
end
p all.sum, row(7)
