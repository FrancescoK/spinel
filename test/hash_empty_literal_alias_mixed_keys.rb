# An empty Hash literal whose key operations, through it and through another
# name for it, disagree on the key's class holds every key it is given.
x = {}
y = x
y[:a] = 1
x["b"] = 2
p x
z = {}
z["b"] = 2
w = z
w[:a] = 1
p z
