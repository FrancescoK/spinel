# --share-strings: a builtin answering a run of its receiver's own elements
# (sort, uniq, drop, reverse, rotate, take, compact, flatten, values_at, a
# counted first, last, min or max) over a container no name holds whose
# elements are new Strings (`"a b".split`, `[+"a", +"b"]`) holds those same
# new Strings, and so does max or min. An element read out of it, kept
# under two names and changed (`y = "a b".split.sort[0]; z = y; y << "!"`),
# was refused (#6765): the run lost the mark of its receiver's new
# elements. Elements a name holds stay that name's.
# spinel: gc-stress

def change(y)
  z = y
  y << "!"
  p z, y.equal?(z)
end
change("a b".split.sort[0])
change("b a".split.uniq[0])
change("a b".split.drop(1)[0])
change("a b".split.reverse[0])
change("a b".split.rotate[0])
change("a b".split.take(1)[0])
change("a b".split.compact[0])
change("a b".split.flatten[0])
change("a b".split.values_at(1)[0])
change("a b".split.first(1)[0])
change("a b".split.last(1)[0])
change("a b".split.min(1)[0])
change("a b".split.max(1)[0])
change("a b".split.max)
change("a b".split.min)
change("a b".split.sort.first)
change("b a".split.sort.reverse.last)
change([+"k", +"j"].sort[0])

# under two local names, without a method between
y = "c d".split.sort[0]
z = y
y << "?"
p z

# elements a name holds are that name's
s = String.new("q")
t = String.new("r")
x = [s, t].sort[0]
x << "!"
p s, x.equal?(s)
w = [+"m", t].reverse[0]
w << "?"
p t, w.equal?(t)
c = "u v".split
d = c.sort[0]
d << "7"
p c, d

# stored, passed, yielded
a = ["x y".split.sort[0]]
b = a[0]
b << "3"
p a
h = {k: "p q".split.reverse.first}
g = h[:k]
g << "5"
p h
def yy = yield("s t".split.uniq.last)
kept = nil
yy { |v| v << "6"; kept = v }
p kept

# a String Range's sorted members
r = (+"a")..(+"c")
e = r.sort[0]
e2 = e
e << "1"
p e2, r
