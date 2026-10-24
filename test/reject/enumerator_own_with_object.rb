# spinel: reject-subclass: Enumerator#with_object of the program's own
# The program gives Enumerator a with_object of its own, which CRuby
# calls for `with_object` on what a method answers without a block. The
# call is rewritten onto each_with_object's walk, which would pass that
# method by, so it is refused rather than answered from the walk.
class Enumerator
  def with_object(memo) = [:own, memo]
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
