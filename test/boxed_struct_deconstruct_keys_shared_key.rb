# A boxed Struct's deconstruct_keys takes a String key the program shares
# (changed in place through another name) as a String key: its handle was
# read as an index, a TypeError.
S = Struct.new(:a, :b)
s = [S.new(1, 2), 5][0]
k = +"a"
k2 = k
k2 << ""
p s.deconstruct_keys([k])
p s.deconstruct_keys([k, :b])
