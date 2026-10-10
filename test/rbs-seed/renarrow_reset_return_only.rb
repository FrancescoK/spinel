# spinel: rbs-seed-run
# spinel: rbs-seed-check
# The re-narrow loop resets a boxed return that feeds the ivar its call
# reads, and with that ivar seeded it resets nothing else. Its plain
# no-change exit then saw infer_return_types re-derive the return every
# iteration and ran the loop's whole 128-iteration cap.
class RnrCpu
  def initialize
    @a = 1
  end

  attr_reader :a

  def step = @a = shifted(@a)
  def shift(value) = shifted(value)
  def shifted(value) = value >> 1
end

c = RnrCpu.new
3.times { c.step }
p c.a
mixed = [3, "x"]
p c.shift(mixed[0])
