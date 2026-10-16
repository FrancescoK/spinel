# The rows zip, product, chunk_while and slice_when build out of a new
# String Array hold its Strings: a change through a row reaches them, and
# shows through every row that holds the same String (#9258)
a = "ab cd ef".split.zip([1, 2, 3])
a[0][0] << "!"
p a
b = [1, 2].zip("gh ij".split)
b[1][1].upcase!
p b
c = "kl mn".split.product([1, 2])
c[0][0] << "?"
p c
d = "op qr st".split.chunk_while { |x, y| y > x }.to_a
d[0][1] << "#"
p d
e = "uv wx yz".split.slice_when { |x, y| false }.to_a
e[0][2] << "$"
p e
c = "kl mn".split.product("op qr".split)
c[0][0] << "?"
c[0][1] << "#"
p c
