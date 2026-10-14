# spinel: share
# spinel: gc-minor
# Under --share-strings, an Array of Strings that another name also holds
# and that a String is changed through holds the Strings themselves: what
# is stored, read and changed is one object.
s = +"s"
a = [s, +"t"]
a << +"u"
a.push(+"v", s)
a[1] = s
a[6] = +"far"
s << "!"
p a
p a[0].equal?(s), a[1].equal?(s), a.first.equal?(s), a[4].equal?(s), a[-1].equal?(s)
a[0] << "?"
a.last << "."
p s, a.size, a.length, a.empty?
p a[5], a[-2], a[9]
t = a[2]
t << "T"
p a[2], t.equal?(a[2])
