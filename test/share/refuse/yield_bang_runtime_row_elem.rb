# A bang on an element of a row each_slice made, handed to a yield: the
# runtime boxed split's Strings as their bytes, so the bang would answer a
# new String the row never sees; the flag refuses the yield.
def pick(v) = v
def z(a) = (yield(a[0].upcase!); p a)
src = pick(1) == 1 ? +"ab,cd" : +"x"
rows = src.split(",").each_slice(1).to_a
z(rows[0]) { |x| x << "!" if x }
