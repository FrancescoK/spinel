# spinel: reject-subclass: Enumerator#with_object of the program's own
# `alias with_object with_index` makes Enumerator's with_object its
# with_index, which CRuby calls (and raises TypeError for the Array memo).
# The alias names a builtin method, no method of the program's; the call
# is refused rather than answered from each_with_object's walk.
class Enumerator
  alias with_object with_index
end
class Walk
  def initialize(xs) = @xs = xs
  def each_item(&blk)
    return to_enum(:each_item) unless blk
    @xs.each(&blk)
    self
  end
end
p Walk.new([1, 2]).each_item.with_object([]) { |x, acc| acc << x }
