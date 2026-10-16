# A new String Array stored straight into a container is the Array of its
# Strings: a change through an element shows through the container (#9258)
h = { k: "ab cd".split }
h[:k][0] << "!"
h[:k][1].upcase!
p h
g = [1, "ef gh".split(" ")]
g[1][0] << "?"
p g
w = h[:k][0]
w << "#"
p h[:k][0].equal?(w), h
