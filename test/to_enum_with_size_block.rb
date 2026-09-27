# `return to_enum(:m) { size } unless block_given?` -- the blockless-branch
# idiom with a size block (activesupport's Enumerable#index_by, index_with,
# Array#extract!). The to_enum rewrite skipped any call carrying a block, so
# the leftover was refused; the size block is dropped (the Enumerator's
# size is not modelled) and the call becomes the generator helper, or the
# blockless builtin iterator, as a bare `to_enum(:m)` already did.
class Bag
  include Enumerable
  def initialize(*xs) = @xs = xs
  def each(&b) = @xs.each(&b)
  def size = @xs.size
  def pairs
    return to_enum(:pairs) { size if respond_to?(:size) } unless block_given?
    @xs.each_cons(2) { |a, b| yield a, b }
  end
  def index_by
    if block_given?
      result = {}
      each { |elem| result[yield(elem)] = elem }
      result
    else
      to_enum(:index_by) { size }
    end
  end
end
b = Bag.new(1, 2, 3)
b.pairs { |x, y| print x, y, " " }
puts
e = b.pairs
p e.next, e.next
p b.pairs.to_a
p b.index_by { |x| x * 10 }
p b.index_by.to_a
p b.to_enum(:each) { size }.first(2)
p [1, 2, 3].to_enum(:each) { 3 }.next
