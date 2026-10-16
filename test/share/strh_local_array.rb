# spinel: share
# spinel: gc-minor
# Under --share-strings, an Array of Strings that are shared with another
# name and changed in place holds the Strings themselves: element reads,
# stores, iteration and the Array's own methods all see one object.

# a literal holding a String changed after it is stored
s = +"ab"
a = [s, "x"]
s << "!"
p a
p a[0].equal?(s), a.first.equal?(s), a[-2].equal?(s)
a[0] << "?"
p s, a.size, a.length, a.empty?

# pushes, then changes through the elements and through the other name
rows = []
3.times { |i| rows << (+"r") + i.to_s }
t = +"t"
rows.push(t)
rows << t
rows.each { |r| r << "\n" }
p rows, t
p rows[3].equal?(rows[4]), rows.last.equal?(t)
rows.each_with_index { |r, i| r << i.to_s if i == 0 }
p rows.first

# reads that copy nothing: join, include?, ==, inspect, interpolation
p rows.join("|")
p rows.include?("t\n\n"), rows.include?("zz")
puts "#{a} #{a.size}"
puts a
p a == [s, "x"]

# map answers new Strings; element store and growth
up = a.map { |e| e.upcase }
p up
a[1] = s
a[3] = t
p a, a[2]
a[1] << "#"
p s, a[0].equal?(a[1])

# pop and shift hand the String itself back
q = [s, t]
x = q.pop
x << "p"
p t, q
y = q.shift
y << "s"
p s, q, q.empty?

# dup is a new Array of the same Strings; to_a is the Array itself
d = rows.dup
d << +"new"
d[0] << "D"
p rows.size, d.size, rows[0]
p rows.to_a.equal?(rows)
r2 = rows[1, 2]
r2[0] << "R"
p rows[1]

# a frozen literal keeps its identity as an element
l = "lit"
f = [s]
f << l
p f[1].equal?(l)
f[0] << "F"
p s

# another local of the same Array
g = a
g << +"g"
p a.size, a.last
