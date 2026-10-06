# A String method that answers a new String does so even when nothing
# changes: center/ljust/rjust wider than the String, sub with no match,
# encode to the same encoding, partition/rpartition with no match, and
# replace. The runtime handed back the receiver's own pointer (and replace
# the argument's), so equal? answered true and freezing one name froze the
# other.
s = +"hello"
p [s.center(2).equal?(s), s.ljust(2).equal?(s), s.rjust(2).equal?(s)]
p [s.center(3, "*").equal?(s), s.ljust(0, "-").equal?(s), s.rjust(1, "+").equal?(s)]
p [s.sub("zz", "y").equal?(s), s.sub(/q/, "y").equal?(s)]
p [s.encode("UTF-8").equal?(s), s.encode("ASCII").equal?(s)]
[s.partition("z"), s.rpartition("z"), s.partition(/z/), s.rpartition(/z/)].each do |a|
  p [a, a.map { |q| q.equal?(s) }, a.map(&:frozen?), a[1].equal?(a[2]), a[0].equal?(a[1])]
end
t = +"a"
t.replace(s)
p [t, t.equal?(s)]
s2 = +"zz"
t2 = +"b"
t2.replace(s2)
s2.freeze
p [t2.frozen?, s2.frozen?]
t2 << "!"
p [t2, s2]

# the unchanged result is a String of its own
c = s.center(1)
c << "!"
p [c, s]
f = "lit"
g = f.ljust(1)
p [g.frozen?, g.equal?(f)]
g << "?"
p [g, f]

# the bang forms still answer nil when nothing changed
u = +"abc"
p [u.sub!("z", "y"), u.sub!(/z/, "y"), u]
