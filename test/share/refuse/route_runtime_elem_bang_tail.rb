# Flag-only: under --share-strings, a bang on an element of a container a
# builtin made, as a block's tail, answers a new String the container never
# sees: refused.
def q = yield
rows = "ab cd ef gh".split.each_slice(2).to_a
w = q { rows[0][0].upcase! }
w << "!"
p rows, w
