# A method declared `-> Array[untyped]` whose value comes from Range#to_a used
# to be refused as a seed contradiction, though the declaration is wider than
# the value -- the direction that widens. The return boundary rebuilds the
# typed array with its elements boxed, the same copy the unseeded compiler
# emits when a caller's use widens such a value, so the seed is satisfied.
# The reverse direction too: `-> Array[Integer]` over a body whose other arm
# is a literal holding an untyped element materializes that literal at the
# boundary instead of handing an sp_PolyArray * through an sp_IntArray *
# signature (#4191).
# spinel: rbs-seed-run
class Pager
  def self.from_range(n)
    return (1..3).to_a if n > 0
    [n]
  end

  def self.only_range(n)
    (1..n).to_a
  end

  def self.strs
    ["a", "bb"].map { |s| s + "!" }
  end
end

class Fixed
  def self.from_range(n)
    return (1..3).to_a if n > 0
    [n]
  end
end

p Pager.from_range(1)
p Pager.from_range(0)
a = Pager.only_range(3)
a.push("x")
p a
p Pager.strs
p Fixed.from_range(1)
p Fixed.from_range(0)
