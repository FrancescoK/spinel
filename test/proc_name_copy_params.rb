# A proc held in a global, or copied from one name into another, takes its
# parameter types from the calls through that name: `$pr.call("abc")` and
# `map(&$pr)` hand it Strings, which it used to read as Integers. sort, min,
# max and minmax given a proc held in a constant or a global run it, where
# they used to sort as without a block.
$pr = proc { |x| x.to_s.size }
p ["bb", "a"].map(&$pr)
p $pr.call("abc")
def via_method(s) = $pr.call(s)
p via_method("hello")

lp = proc { |x| x.to_s * 2 }
$lp = lp
p $lp.call("ab"), ["x", "yz"].map(&$lp)
pr = proc { |x| x.to_s.size }
q = pr
p q.call("abc"), ["bb", "a"].map(&q)
$f = proc { |s| s.size }
$f2 = $f
p $f2.call([1, 2, 3])
$up = lambda { |s| s.upcase }
p %w[a b].map(&$up)

$len3 = proc { |s| s.size == 3 }
p $len3 === "abc"
p(case "xyz"; when $len3 then :three; else :other; end)

$cmp = proc { |a, b| b <=> a }
p [1, 3, 2].sort(&$cmp), [1, 3, 2].min(&$cmp), [1, 3, 2].max(&$cmp)
p ["b", "c", "a"].sort(&$cmp), ["b", "c", "a"].minmax(&$cmp)
a = ["b", "c", "a"]
a.sort!(&$cmp)
p a
CMP = proc { |a, b| b <=> a }
p [1, 3, 2].sort(&CMP), [1, 3, 2].max(&CMP)
module M
  CMP = proc { |a, b| b.size <=> a.size }
end
p ["bb", "a", "ccc"].sort(&M::CMP), ["bb", "a", "ccc"].min(&M::CMP)
class K
  def initialize
    @cmp = proc { |a, b| b <=> a }
    @pr = proc { |x| x.to_s.size }
  end
  def run = [1.5, 3.5, 2.5].sort(&@cmp)
  def low = ["q", "z"].min(&@cmp)
  def sizes = ["bb", "a"].map(&@pr)
end
k = K.new
p k.run, k.low, k.sizes
