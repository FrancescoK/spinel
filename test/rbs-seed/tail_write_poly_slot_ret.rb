# A method seeded `-> Integer` whose last expression writes a slot some other
# write left poly answers the value written: the write was emitted as a
# statement and the method answered nil, which a caller's `<< 8` then
# refused as an overflow.
class TwByte
  def peek(addr) = addr & 0xff
end

class TwText
  def peek(addr) = addr > 0xffff ? "open" : 7
end

class TwBus
  attr_reader :data

  def initialize
    @pages = [TwByte.new, TwText.new]
    @data = 0
  end

  def peek(addr)
    @data = @pages[addr & 1].peek(addr)
  end

  def peek16(addr) = (peek(addr + 1) << 8) + peek(addr)

  def local(addr)
    value = @pages[addr & 1].peek(addr)
  end

  def global(addr)
    $tw_last = @pages[addr & 1].peek(addr)
  end
end

bus = TwBus.new
p bus.peek(2)
p bus.peek16(2)
p bus.data
p bus.local(3)
p bus.global(2)
$tw_last = "none"
