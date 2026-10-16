# spinel: share
# spinel: gc-minor
# An Array of shared Strings keeps the form that holds each String's handle
# only while every value it can hold is a String and every use of it is one
# the form answers; any other use leaves it the general Array, which answers
# as it always did.
s = +"s"

# a non-String pushed or stored
a = [s]
a << 1
a << nil
a << :sym
s << "!"
p a, a.size, a[0]
a[1] = "str"
p a

# a nil written into a literal of Strings
b = [s, +"t"]
b[0] = nil
p b

# operations the form does not answer itself
m = [s, +"m"]
p m.map { |e| e.size }, m.map { |e| e.upcase }
m.map { |e| e }.each { |e| e << "." }
p m
c = [s, +"b", +"a"]
p c.sort, c.sort_by { |e| e.size }, c.reverse, c.rotate, c.uniq, c.min, c.max
p c.index("a"), c.count, c.take(2), c.select { |e| e.size > 1 }
c.concat([+"z"])
c.insert(1, +"ins")
c.unshift(+"u")
p c
c.sort!
c.each { |e| e << "." }
p c, s

# nested in another Array or a Hash
n = [[s], [+"k"]]
n[0][0] << "n"
p n, s
h = { k: [s, +"hv"] }
h[:k] << +"third"
p h

# a user class's each, whose block's value the block's last statement is
w = [s, +"t"]
w2 = [s, +"t"]
class Walker
  def each
    yield.size
  end
end
p Walker.new.each { w[0] }, Walker.new.each { w2.first }
w[1] << "!"
p w, w2, s

# destructuring block parameters
dd = [s, +"d"]
dd.each { |(x)| x << "D" }
d2 = [s, +"d"]
d2.each { |(x, y)| x << "E" }
p dd, d2

# a write or a store whose value is used
def first_row
  t = +"w"
  rows = [t]
  t << "!"
  x = rows[0]
end
fr = first_row
fr << "V"
p fr
def put_row
  t = +"w"
  rows = [t]
  t << "!"
  rows[0] = +"n"
end
pr = put_row
pr << "V"
p pr
m1 = [s, +"t"]
m1[0] = (m1[1] = +"q")
m2 = [s, +"t"]
m2 << (m2[1] = +"q")
xv = (m2[0] = +"r")
xv << "X"
p m1, m2, s

# a safe navigation on an element that can be nil
sn = [s, +"t"]
p sn[5]&.size, sn[0]&.size
