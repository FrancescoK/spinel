# spinel: share
# spinel: gc-minor
# join, include? and == evaluate their receiver before their argument: an
# argument that rebinds the receiver's variable leaves the operation on the
# Array it started with, wherever the C compiler orders a call's arguments.
s = +"ab"
a = [s, "x"]
s << "!"
sep = a.join((a = [+"z", +"y"]; "-"))
p sep, a

b = [s, "x"]
s << "?"
q = b.include?((b = [+"k"]; "x"))
p q, b

c = [s, "x"]
s << "."
r = c == (c = [s, "x"])
p r, c

# an argument that reads the Array, or changes a String of it
d = [s, +"d"]
p d.join(d.first), d.include?(d.pop)
e = [s, +"e"]
p e.join((e[1] << "!"; "|")), e
