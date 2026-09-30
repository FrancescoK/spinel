# The run-time nil flag of an Integer array (#6412) follows an intersection
# with an operand analyze marked, and the offset pair of a group that did
# not take part in the match.
def t
  yield
rescue => e
  e.class
end

# a gap left by a computed-index write, intersected with an array whose
# nil analyze saw
i = 3 + ARGV.size
a = [1, 2]
a[i] = 5
x = ARGV.empty? ? nil : 1
b = [2, 7]
b.push(x)
c = a & b
p c, c.include?(nil), c.count(nil), c.all?
p t { c.sum }, t { c.max }
d = a.intersection(b)
p d.include?(nil), t { d.sum }

# a valid group that did not match: offset is [nil, nil]
m = /(a)|(b)/.match("b")
o = m.offset(1)
p o, o.include?(nil), o.count(nil), o.all?
p t { o.sum }, t { o.max }
q = m.byteoffset(1)
p q.include?(nil), t { q.sum }
p m.offset(2), m.offset(2).sum

# Float rows with a gap, transposed: the column holds the nil
f = [1.5]
f[2 + ARGV.size] = 2.5
g = [0.5, 1.0, 2.0]
cols = [f, g].transpose
cols.each { |col| p [col.all?, col.count(nil), t { col.sum }, t { col.max }] }
