# An empty fold retains its initializer handle.
s = +"a"
a = []
r = a.sum(s)
r << "!"
p [s, r]

s = +"t"
r = ["a", "b"].sum(s)
r << "?"
p [s, r]
a = [+"x", +"y"]
r = a.sum(+"")
r << "!"
p [a, r]
