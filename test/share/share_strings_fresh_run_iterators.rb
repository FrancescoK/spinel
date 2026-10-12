# --share-strings: a blockless run of an Array no name holds whose elements
# are new Strings (`"b a".split.sort`, `.uniq`, `.drop(0)`) holds those same
# new Strings, so an iterator with a block over it (sort_by, sort, select,
# each_slice map) walks it as the PolyArray of handles it walks the Array
# itself as. An element read out of the iterator's answer, kept under two
# names and changed, was refused, and each_with_index.map did not build
# (#6765).
# spinel: gc-stress

def change(y)
  z = y
  y << "!"
  p z, y.equal?(z)
end
change("b a".split.sort.sort_by(&:size)[0])
change("b a".split.uniq.sort_by { |x| x.size }[0])
change("b a".split.drop(0).sort { |p1, p2| p2 <=> p1 }[0])
change("b a".split.sort.each_slice(1).map { |x| x[0] }[1])
change("b a".split.sort.select { |x| x }[0])
change("b a".split.sort.reverse.sort_by(&:size)[0])

$k = nil
"b a".split.sort.each { |x| $k = x }
$k << "!"
p $k
r = "d c".split.uniq
r2 = r.sort_by(&:size)
r2[0] << "1"
p r, r2
w = "h g".split.sort.each_with_index.map { |x, i| x }
w[0] << "4"
p w
s = String.new("s")
n = [s, +"t"].sort.sort_by(&:size)
n[0] << "3"
p s, n
