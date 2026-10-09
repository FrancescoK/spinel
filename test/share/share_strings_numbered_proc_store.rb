# spinel: share
# spinel: gc-minor
# Numbered and implicit parameters use the same shared binding as named ones.
kept = []
store = proc { kept << _1 }
store.call(+"numbered")
store.call(7)
kept[0] << "!"
p kept
other = []
f = -> { other << _1 }
f.call(+"lambda")
f.call(8)
other[0] << "?"
p other
its = []
g = proc { its << it }
g.call(+"it")
g.call(9)
its[0] << "."
p its
implicit = []
h = -> { implicit << it }
h.call(+"implicit")
h.call(10)
implicit[0] << ":"
p implicit
second = []
j = -> { second << _2 }
j.call(0, +"second")
j.call(0, 11)
second[0] << "/"
p second
shared = +"shared"
f.call(shared)
other[2] << "!"
p [shared, other[2], shared.equal?(other[2])]
f.call("fixed")
begin
  other[3] << "!"
rescue FrozenError
  puts "frozen"
end
p other[3].frozen?
f.call("same")
f.call("same")
p other[4].equal?(other[5])
