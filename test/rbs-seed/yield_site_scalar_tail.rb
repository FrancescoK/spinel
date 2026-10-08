# `yield` carries the union of every call site's block, so a slot fed from it
# is typed poly. The block spliced at one particular site can still hand back a
# scalar, and coercing THAT through the poly unbox is not merely redundant: the
# emitted C unboxes a value that was never boxed and does not compile. The
# coercion asks the block being spliced here, not the union.
# spinel: rbs-seed-run
class YsBag
  def [](k)
    "bag"
  end
end

class YsRel
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

p YsBag.new[1]

# one site whose block value stays poly, one whose block value is an Integer
poly_keyed = YsRel.new([1, 2, 3]).group { |x| x }
p poly_keyed[2]

int_keyed = YsRel.new(["a", "bb", "c"]).group { |s| s.length }
p int_keyed[1]
p int_keyed[2]
p int_keyed.length

# and one whose block value is a String, through the same method
str_keyed = YsRel.new([1, 22]).group { |n| n.to_s }
p str_keyed["1"]
p str_keyed["22"]
# a float-valued block over the same union
flt_keyed = YsRel.new([1, 2]).group { |n| n * 1.5 }
p flt_keyed[1.5]
p flt_keyed[3.0]
