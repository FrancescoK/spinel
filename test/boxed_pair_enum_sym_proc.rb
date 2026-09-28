# &:m over an Enumerator yielding two values calls m on the first with the
# second, when the Enumerator arrives boxed or stored

mixed = [[[1, 2], [3, 4]].each_with_index, [[5, 6]].each.with_index(1),
         [[7, 8]].each_with_object(1), [[9, 10]].each, [[11, 12]]]
mixed.each { |en| p en.map(&:first) }
mixed.each { |en| p en.map(&:last) }
mixed.first(3).each { |en| p en.map(&:[]) }
mixed.first(3).each { |en| p en.collect(&:<=>) }

nums = [[10, 20].each_with_index, [3, 4].each.with_index(1), %w[a b].each_with_object("x")]
nums.each { |en| p en.map(&:+) }
nums.each { |en| p en.map(&:==) }

e = [10, 20].each_with_index
p e.map(&:+)
p e.map(&:<=>)
p e.map(&:-).sum
p e.flat_map(&:*)
p e.count(&:>)

g = %w[a b].each.with_index
p g.map(&:*)

h = [[1], [2]].each_with_object([9])
p h.map(&:+)

class Holder
  def initialize(en)
    @en = en
  end

  def sums = @en.map(&:+)
  def firsts = @en.map(&:first)
end
p Holder.new([10, 20].each_with_index).sums
p Holder.new([[1, 2]].each_with_index).firsts

def pair_sums(en) = en.map(&:+)
p pair_sums([10, 20].each_with_index)
p pair_sums([1, 2].each_with_index)

def firsts(en) = en.map(&:first)
p firsts([[1, 2]].each_with_index)
p firsts([[1, 2]].each)
p firsts([[1, 2]])
