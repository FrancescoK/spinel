# find_index(v) that misses on a mixed Array or a Hash answers nil, also
# when the answer is stored in a local.

m = [1, "a"]
r = m.find_index(9)
p r.nil?
p (m.find_index(9) || -1) + 1
x = m.find_index("a")
p x + 1 if x
h = {a: 1}
y = h.find_index([:b, 2])
p y
y = h.find_index([:a, 1])
p y
z = [1.5, nil].find_index(nil)
p z
