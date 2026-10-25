# spinel: reject-subclass: Hash#transform_values on a value typed as Hash, a call no route of the compiler took
# A call of a method a Hash has, on a value typed as a Hash, that no route
# of the compiler takes (here the blockless form, which answers an
# Enumerator in CRuby): refused at compile time, naming the method, rather
# than raising NoMethodError for a method CRuby calls.
h = { a: 1, b: 2 }
e = h.transform_values
p e.class
