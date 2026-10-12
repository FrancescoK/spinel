# --share-strings: sort_by and sort with a block over an Array no name holds
# whose elements are new Strings (`"b a".split.sort_by(&:size)`) answer
# those same Strings, reordered. An element read out of the answer, kept
# under two names and changed, was refused (#6765): the block's parameter
# is the element itself, which the share rule shares, and the typed sort
# walked copies. The sort now walks the PolyArray of handles a local's
# Array would be, as select does, and answers it, so a block that keeps
# its parameter keeps the element the answer holds.
# spinel: gc-stress

def change(y)
  z = y
  y << "!"
  p z, y.equal?(z)
end
change("b a".split.sort_by { |x| x }[0])
change("bb a".split.sort_by(&:size)[0])
change("a b".split.sort { |p1, p2| p2 <=> p1 }[0])
change("a b".split.sort_by(&:size).reverse[0])
change("b a".split.sort { |p1, p2| p1 <=> p2 }.first(1)[0])
change("a bb".split.sort_by(&:size).max)

# a block that keeps its parameter, changes it, or compares identities
kept = nil
w = "q p".split.sort { |a, b| kept ||= a; a <=> b }
w[0] << "?"
p w, kept, w.any? { |v| v.equal?(kept) }
m = "n m".split.sort_by { |v| v << "#"; v.size }
p m
p "y x".split.sort { |a, b| p a.equal?(b); a <=> b }

# elements a name holds are that name's
s = String.new("s")
t = String.new("t")
named = [t, s].sort_by(&:itself)
named[0] << "1"
p s, t, named
mixed = [+"k", s].sort_by { |v| v.size }
mixed.each { |v| v << "2" }
p s, mixed

# stored, mapped, yielded
h = {k: "u v".split.sort_by(&:size)}
h[:k][1] << "3"
p h
p "e d".split.sort_by(&:size).map(&:upcase)
def yy = yield("i h".split.sort_by(&:size).first)
got = nil
yy { |v| v << "4"; got = v }
p got
