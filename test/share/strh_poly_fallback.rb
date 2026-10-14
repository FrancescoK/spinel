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

# handed to a method, returned from one, yielded, nested in another
def size_of(list) = list.size
def build = [+"x", +"y"]
def mutate(list) = list.each { |e| e << "m" }
d = [s, +"w"]
p size_of(d)
mutate(d)
p d
e = build
e.each { |v| v << "b" }
p e
def twice
  yield [+"p"]
  yield [+"q"]
end
twice { |list| list << +"r"; p list }
n = [[s], [+"k"]]
n[0][0] << "n"
p n, s
h = { k: [s, +"hv"] }
h[:k] << +"third"
p h
