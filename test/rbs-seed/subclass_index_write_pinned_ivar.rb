# spinel: rbs-seed-run
# A subclass that only index-writes an ivar its superclass assigns and the
# seed pins as Array[Integer]. The subclass's slot read as untyped there, so
# `@inputs[0] = 0xff` made it an Integer-keyed Hash, the pin kept the
# superclass's Array, and the program was refused: "class layout: @inputs is
# `sp_RbVal` in PinnedPortChip but `sp_IntArray *` in its ancestor PortChip".
# Unseeded, the same write boxed the slot in the whole family.
class PortChip
  attr_reader :inputs

  def initialize
    @inputs = [0, 0, 0]
  end

  def peek(port) = @inputs[port] & 0xff
end

class PinnedPortChip < PortChip
  def initialize(level)
    @level = level
    super()
    @inputs[0] = 0xff
  end

  def peek(port)
    @inputs[1] = @level if port == 1
    super
  end
end

chip = PinnedPortChip.new(7)
p chip.peek(0), chip.peek(1), chip.peek(2)
p chip.inputs
p PortChip.new.peek(0)
