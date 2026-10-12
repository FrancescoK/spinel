# `super` in a freeze override that no ancestor defines is Object#freeze: the
# object frozen, answering itself (Thor's HashWithIndifferentAccess#freeze).
class Box
  def initialize
    @items = [1]
  end

  def freeze
    @items.freeze
    super
  end

  def items = @items
end

b = Box.new
r = b.freeze
p [r.equal?(b), b.frozen?, b.items.frozen?]
