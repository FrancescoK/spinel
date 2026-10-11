# A bare `new(...)` in a class method builds an instance of that class, so
# an argument that may be a nil Integer makes initialize's parameter
# nullable, as `W.new(k)` does (#8572). The argument is `timing.clock_hz`
# on a boxed receiver, where one candidate answers an Integer that may be nil.
Timing = Data.define(:clock_hz, :lines)

class Player
  def initialize(hz) = @hz = hz
  def clock_hz = @hz[0]
end

class FrameRate
  def self.machine(timing)
    new(timing.lines, timing.clock_hz)
  end

  def self.through_local(timing)
    hz = timing.clock_hz
    new(timing.lines, hz)
  end

  def initialize(lines, clock_hz)
    @lines = lines
    @clock_hz = clock_hz
  end

  attr_reader :clock_hz
end

p Player.new([985_248]).clock_hz
t = [Timing.new(clock_hz: 985_248, lines: 312), "x"][0]
p FrameRate.machine(t).clock_hz
p FrameRate.through_local(t).clock_hz
p FrameRate.machine([Timing.new(clock_hz: nil, lines: 1), "x"][0]).clock_hz
