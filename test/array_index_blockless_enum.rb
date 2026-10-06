# Array#index / #rindex with no argument and no block answer an Enumerator
# whose each block picks the index, as find_index's does (with no size).
# They raised NoMethodError.
a = [3, 1, 4, 1, 5]
e = a.index
p e.class
p e
p e.size
p e.each { |x| x == 1 }
r = a.rindex
p r
p r.size
p r.each { |x| x == 1 }
p a.index.to_a
p a.find_index.size
p ["a", "b"].index
p a.index { |x| x > 3 }
p a.rindex { |x| x > 3 }
p a.index(4)
p a.rindex.to_a
p a.rindex
