# An if / elsif arm answering an Integer or Float that may be nil, read
# into a boxed result (here a poly ivar): the arm was unwrapped before it
# was boxed, so a nil raised TypeError ("no implicit conversion from nil
# to integer") where CRuby answers nil.
class Memory
  def initialize(cells) = @cells = cells
  def peek(addr) = @cells[addr]
  def ratio(addr) = (v = @cells[addr]) && v / 2.0
end

class ColorMemory < Memory
  def peek(addr) = (v = @cells[addr]) && v & 0x0f
end

class Bus
  def initialize
    @ram = Memory.new([1, 2])
    @data = 0
  end

  def poke(value) = @data = value

  def peek(addr)
    @data = if addr < 0x0800
              @ram.peek(addr)
            elsif addr < 0x1800
              @data
            end
  end

  def ratio(addr)
    @data = if addr < 0x0800
              @ram.ratio(addr)
            else
              @data
            end
  end

  def low(addr)
    @data = unless addr >= 0x0800
              @ram.peek(addr)
            else
              :high
            end
  end
end

p ColorMemory.new([0x13]).peek(0)
bus = Bus.new
p bus.peek(1)
p bus.peek(5)
p bus.peek(0x1000)
p bus.ratio(1)
p bus.ratio(5)
p bus.low(0)
p bus.low(7)
p bus.low(0x1000)
bus.poke("x")
p bus.peek(0x1000)
