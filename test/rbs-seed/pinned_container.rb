# An --rbs ivar seed must survive the whole fixpoint. @kids is only ever
# lazy-initialized (`||= []`, an IntArray-typed empty literal) and pushed
# through the bang reader, so inference alone widens it to poly (the usage
# pass never sees a direct `@kids <<` push); the Array[untyped] seed pins it
# to a poly array, keeping size / all? / element reads dispatchable. @meta
# likewise stays str_poly_hash instead of demoting to poly_poly_hash when
# read into an untyped local.
# spinel: rbs-seed-check
class PinItem
  attr_reader :label
  def initialize(label)
    @label = label
  end
end

class PinBox
  EMPTY = [].freeze

  def kids
    @kids || EMPTY
  end

  def kids!
    @kids ||= []
  end

  def meta!
    @meta ||= {}
  end
end

box = PinBox.new
box.kids! << PinItem.new("a")
box.kids! << PinItem.new("b")
puts box.kids.size
puts box.kids.all? { |k| !k.label.nil? }
puts box.kids[0].label
box.meta!["x"] = 7
local = box.meta!
puts local["x"]
