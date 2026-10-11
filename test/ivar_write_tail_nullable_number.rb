# A method whose last statement writes an Integer or Float ivar that can
# hold nil answers what it wrote: the answer read the field without its
# nil bit, so a nil came back as 0 (or 0.0).
class Memory
  def initialize(cells) = @cells = cells
  def peek(addr) = @cells[addr]
end

class Bus
  def initialize
    @ram = Memory.new([1, 2])
    @data = 0
    @level = 0.5
  end

  def peek(addr)
    @data = if addr < 0x0800
              @ram.peek(addr)
            elsif addr < 0x1800
              @data
            end
  end

  def level(on)
    @level = on ? 1.5 : nil
  end

  def describe(addr)
    v = peek(addr)
    v.nil? ? "none" : "got #{v}"
  end
end

bus = Bus.new
p bus.peek(1)
p bus.peek(5)
p bus.peek(0x1000)
p bus.peek(0x2000)
p bus.level(true)
p bus.level(false)
puts bus.describe(0)
puts bus.describe(9)
