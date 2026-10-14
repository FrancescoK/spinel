# spinel: share
# spinel: gc-minor
# Under --share-strings an Array of shared Strings is held as their handles
# across a method's parameter too: the caller's names, the parameter and
# whatever it is handed on to are one Array, so a change through any of them
# shows through every other, and no copy sits between two names.
def add(list, s)
  list << s
  list[0] << "!"
  list.size
end
def bang(list)
  list.each { |x| x << "." }
  list
end

# changed through the parameter, read through the caller's name
t = +"t"
rows = [+"r0"]
p add(rows, t)
rows.each { |r| r << "?" }
p rows, t, rows.last.equal?(t)

# handed on, aliased in the callee, and returned
def c3(x) = x[0] << "3"
def b2(x)
  x.each { |e| e << "2" }
  c3(x)
end
def a1(x)
  y = x
  y << +"A"
  b2(y)
  x.size
end
r = [t, +"u"]
p a1(r)
r[0] << "~"
p r, t
same = bang(r)
same << +"n"
p r.size, same.size, t

# recursion
def grow(list, n)
  return list if n == 0
  list << +"n#{n}"
  grow(list, n - 1)
end
g = grow([t], 3)
g[0] << "&"
p g, t

# several receivers reaching one method
class A
  def add(l, s) = l << s
end
class B
  def add(l, s)
    l << s
    l[0] << "B"
  end
end
poly = [+"p"]
[A.new, B.new].each { |o| o.add(poly, t) }
poly.each { |e| e << "." }
p poly, t

# a constructor parameter kept in an instance variable
class Box
  def initialize(list)
    @list = list
  end
  def add(s) = @list << s
  def bang = @list.each { |x| x << "!" }
  def dump = p(@list)
end
shared = [t]
b = Box.new(shared)
b.add(+"u")
shared << +"v"
b.bang
shared[0] << "?"
b.dump
p shared, t

# a zsuper hands the parameter on
class P
  def go(a) = a.each { |x| x << "P" }
end
class Q < P
  def go(a)
    a << +"q"
    super
  end
end
z = [t, +"u"]
Q.new.go(z)
p z, t

# allocation across the calls
big = []
300.times do |i|
  row = +"row"
  add(big, row) if i % 3 == 0
  big << row
  row << i.to_s
  GC.start if i % 100 == 0
end
p big.size, big[0], big[-1]
