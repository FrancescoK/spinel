# A bare attr_reader call on an Integer ivar inside the class reads the
# field in the form it is stored: the plain Integer when the ivar is never
# nil, the value with its nil bit when it can be (an operand, an Array
# element, an interpolation).

class Sprite
  attr_reader :index

  def initialize(index, registers)
    @index = index
    @registers = registers
  end

  def x = @registers[index * 2]

  def color = @registers[0x27 + index] & 0x0f
end

regs = Array.new(64) { |i| i + 3 }
sprites = Array.new(8) { |i| Sprite.new(i, regs) }
puts sprites[0].x
puts sprites[3].x
puts sprites[1].color

class Slot
  attr_reader :index

  def initialize(index)
    @index = index
  end

  def pointer = 0x400 + index
  def doubled = index * 2
end

slots = [Slot.new(5), Slot.new(nil)]
puts slots[0].pointer
puts slots[0].doubled
begin
  slots[1].pointer
rescue NoMethodError, TypeError => e
  puts e.class
end

class Tile
  attr_reader :index

  def initialize(index)
    @index = index
  end

  def offset = index * 16
end

class BlankTile < Tile
  def index = 0
end

puts Tile.new(3).offset
puts BlankTile.new(3).offset

class Cell
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def pair = [value, 1]
  def label = "value=#{value}"
end

p Cell.new(nil).pair
p Cell.new(2).pair
puts Cell.new(nil).label
puts Cell.new(4).label
