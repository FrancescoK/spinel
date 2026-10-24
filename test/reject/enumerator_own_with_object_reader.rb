# spinel: reject-subclass: Enumerator#with_object of the program's own
# An attr_reader gives Enumerator a with_object of the program's own: CRuby
# calls the reader, which takes no argument, and raises ArgumentError. The
# call is refused rather than answered from each_with_object's walk.
class Enumerator
  attr_reader :with_object
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
