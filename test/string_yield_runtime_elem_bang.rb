# A bang on an element of an Array a builtin made, handed to a block as its
# argument (`yield rows[0][0].upcase!`), answers the element's own String: a
# change the block makes shows in the Array, as in CRuby. The block's binder
# was refused the argument as one that would hand on a copy.
def g(rows) = yield rows[0][0].upcase!

rows = "ab cd ef gh".split.each_slice(2).to_a
g(rows) { |w| w << "!" }
p rows

def pick(v) = v
def z(a) = (yield(a[0].upcase!); p a)
src = pick(1) == 1 ? +"ab,cd" : +"x"
rows2 = src.split(",").each_slice(1).to_a
z(rows2[0]) { |x| x << "!" if x }
