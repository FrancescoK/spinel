# When a user class owns a container method name, the poly dispatch takes its
# return type for the whole call -- so a Hash reaching the same call had its
# answer unboxed into whatever slot that user method needed, or the call was
# typed as having no value at all. Both are the receiver's answer, not the
# name owner's, once the dispatch ends in a runtime helper: the call is the
# union, which is poly.
# spinel: rbs-seed-run
class PcBag
  def [](k); "bag"; end
  def delete(k); "bd"; end
  def dig(*ks); "bdig"; end
  def values_at(*ks); ["bv"]; end
end

class PcRel
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

# the user class still answers for itself
b = PcBag.new
p b[1]
p b.delete(1)
p b.dig(1)
p b.values_at(1)

h = PcRel.new([1, 2]).group { |n| n * 1.5 }

# delete answers the deleted VALUE, not the name owner's String
p h.delete(1.5)
p h.length
p h.delete(9.9)
p h.values_at(3.0)
p h.dig(3.0)

# `each` on a poly receiver answers the receiver, so a chain off it resolves
g = PcRel.new([1, 2]).group { |n| n }
p g.each { |k, v| }.length
p g.each { |k, v| }.keys.length
seen = 0
g.each { |k, v| seen += 1 }
p seen
