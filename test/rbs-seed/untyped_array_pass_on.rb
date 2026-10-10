# spinel: rbs-seed-run
# An Array passed on through an --rbs `untyped` parameter reaches an
# `Array[untyped]` one whole: an Integer Array was read as a poly array and
# arrived empty (#8452). A poly Array and nil pass as they are.
class PassFinder
  def find(ids)
    find_ids(ids)
  end
  def find_ids(ids)
    p ids
    ids ? ids.size : -1
  end
end
f = PassFinder.new
p f.find([1, 999])
p f.find(["a", 2, :b])
p f.find(nil)
