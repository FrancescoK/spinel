# An --rbs seed that names a class the program does not have is ignored, and
# says so. `Bus` below is written unqualified in a namespace whose signatures
# declare no Bus, and with Dock::Bus beside Lane::Bus the leaf name matches
# neither; before the warning the seed was dropped without a word. A seed
# naming a builtin (Time) or a class the program has (Lane::Wire, through the
# declared sibling) stays quiet.
# spinel: rbs-seed-check
module Lane
  class Bus
    def peek(a) = a + 1
  end

  class Wire
    def level = 1
  end

  class Probe
    def initialize(bus, wire)
      @bus = bus
      @wire = wire
      @at = Time.at(0)
    end

    def step(a) = @bus.peek(a) + @wire.level

    def poke(bus, a) = bus.peek(a)
  end
end

module Dock
  class Bus
    def peek(a) = a + 2
  end
end

probe = Lane::Probe.new(Lane::Bus.new, Lane::Wire.new)
p probe.step(1)
p probe.poke(Lane::Bus.new, 2)
p Dock::Bus.new.peek(3)
