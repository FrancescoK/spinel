# A bare call to an attr_reader of an Integer ivar that may be nil, inside
# the class, used as an arithmetic operand: the reader answers the field
# with its nil, as `@index` and `self.index` do (#8570).
class Sprite
  attr_reader :index

  def initialize(index)
    @index = index
  end

  def pointer = 0x400 + 0x3f8 + index
  def left = index + 0x400
  def stored
    v = 0x400 + index
    v
  end
  def explicit = 0x400 + self.index
end

sprites = [1, 2].map { |i| Sprite.new([3, 4][i]) }
puts sprites[0].pointer
puts sprites[0].left
puts sprites[0].stored
puts sprites[0].explicit
puts 0x400 + sprites[0].index
begin
  Sprite.new([nil][0]).pointer
rescue TypeError, NoMethodError => e
  puts e.class
end
