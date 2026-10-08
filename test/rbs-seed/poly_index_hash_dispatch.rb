# A `[]` read on a poly receiver emits a cls_id switch: an arm per user class
# that defines `[]`, then one per builtin ARRAY kind. A Hash arriving at the
# same read matched none of them, and with no default arm the result kept its
# nil initializer, so the read answered nil with nothing raised (#3507). The
# switch now ends in the runtime index, which dispatches on the receiver's own
# kind.
# spinel: rbs-seed-run
class PxBag
  def [](k)
    "bag"
  end
end

class PxRel
  def initialize(items)
    @items = items
  end

  def group
    out = {}
    @items.each do |x|
      k = yield x
      a = out.fetch(k, nil)
      if a.nil?
        a = []
        out[k] = a
      end
      a << x
    end
    out
  end
end

p PxBag.new[1]

rel = PxRel.new([1, 2, 3])
groups = rel.group { |x| x }
p groups.length
p groups[2]
p groups[1]
p groups[99]

# the same read with keys of another kind
strs = PxRel.new(["a", "bb"]).group { |s| s }
p strs["a"]
p strs["bb"]

# and the array kinds the switch already covered stay working
p [10, 20][1]
p ["a", "b"][0]
p [1.5, 2.5][1]
p [[1], [2]][0]

# `fetch` reaches the same dispatch, and its arms cover only string- and
# symbol-keyed hashes: a float-keyed one emitted no dispatch at all and raised
# NoMethodError naming Hash. It ends in the runtime fetch now, which knows a
# Hash miss from an Array one and raises the right error for each.
flt = PxRel.new([1, 2]).group { |n| n * 1.5 }
p flt.fetch(1.5, "miss")
p flt.fetch(9.9, "miss")
p flt.fetch(3.0)
p (flt.fetch(9.9) rescue $!.class)

ints = PxRel.new([1, 2]).group { |n| n }
p ints.fetch(1, "miss")
p ints.fetch(9, "miss")
p (ints.fetch(9) rescue $!.class)

strs = PxRel.new(["a"]).group { |s| s }
p strs.fetch("a", "miss")
p strs.fetch("z", "miss")

# `dig` is one more name a user class can own, taking the whole dispatch with
# it: a Hash arriving at the same call raised NoMethodError naming Hash. It
# ends in the runtime helper too, so the receiver answers for itself.
p flt.dig(1.5)
p flt.dig(9.9)
p ints.dig(1)
nested = PxRel.new([1]).group { |n| n }
p nested.dig(1, 0)

# Keyed by a nil literal, on the same dispatch. `hash[nil]` is the root lookup
# of the group_by-then-find-the-parentless idiom, and a nil key is neither an
# offset nor one of the enumerated hash-key kinds, so it reached the default
# only once the default stopped living in the integer-key branch (#3508).
roots = PxRel.new([1, 2, 3]).group { |x| x == 1 ? nil : x }
p roots[nil]
p roots[2]
p roots.fetch(nil, "miss")
p roots.dig(nil)
p roots.length

mixed = {}
mixed["a"] = [1]
mixed[nil] = [2]
p PxBag.new[:sym]
p mixed[nil]
p mixed["a"]
p mixed[:missing]

# `dig(*keys)` hands the dispatch one temp holding an array, not one temp per
# key, so the arms cannot address the keys -- admitting the name would emit
# argument temps that do not even type-check. The splat form keeps whatever the
# general path emits.
def dig_splat(c, ks)
  c.dig(*ks)
end
p (dig_splat(flt, [1.5]) rescue $!.class)
