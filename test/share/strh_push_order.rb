# spinel: share
# spinel: gc-minor
# push appends its arguments after it has evaluated all of them: a later
# argument that reads the Array, or takes from it, sees the Array as it was.
s = +"ab"
a = [s, "x"]
s << "!"
a.push(+"1", a.last)
p a

b = [s, "x"]
b.push("n", b[-1], b.size.to_s)
p b

c = [s, "x"]
c.push(+"1", c.shift)
p c

d = [s, "x"]
d.push(+"1", d.pop, d.last)
p d

e = [s, +"e"]
e.push(+"f", e.join("-"), e.first)
s << "?"
p e, e[4].equal?(s)

# a later argument that raises leaves the Array as it was
g = [s, "g"]
begin
  g.push(+"h", g.fetch(9))
rescue IndexError => err
  puts err.message
end
p g
