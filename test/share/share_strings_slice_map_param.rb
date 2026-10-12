# --share-strings: each_slice(n).map and each_cons(n).map with one block
# parameter over an Array no name holds whose elements are new Strings: the
# parameter, a slice the share rule boxes, took the typed slice, and the C
# did not build. It now takes the slice boxed, over the Array walked as its
# handles, so an element read out of the answer is the element itself.
# spinel: gc-stress

def change(y)
  z = y
  y << "!"
  p z, y.equal?(z)
end
change("a b".split.each_slice(1).map { |x| x }[0][0])
change("a b".split.each_slice(1).map { |x| x[0] }[1])
change("a b c".split.each_cons(2).map { |x| x[1] }[0])
p "a b c".split.each_cons(2).map { |x| x[1] << "#"; x }
p "d e f".split.each_slice(2).map { |x| x.size }
