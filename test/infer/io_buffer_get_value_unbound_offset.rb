# `get_value` with a literal type symbol answers the symbol's type once its
# offset is an Integer. The offset here is a parameter, so on the rounds
# before a call site binds it the offset is untyped, and the call answered the
# generic binding's boxed value instead of waiting. That boxed value reached
# `step`, and the call cycle through `twice` held it after the offset
# settled: the re-narrow resets parameters and locals but not the return of
# `twice`, which handed the boxed value straight back. Every method below
# came out boxed although each only ever sees an Integer.
class Memory
  def initialize
    @buffer = IO::Buffer.new(16)
    @buffer.set_value(:u32, 4, 7)
  end

  def load(addr) = @buffer.get_value(:u32, addr)
end

class Machine
  def initialize = @memory = Memory.new

  def twice(x) = x * 2 & 0xffffffff

  def step(a)
    b = a + 1 & 0xffffffff
    a = twice(b) if b & 1 != 0
    a
  end

  def run = step(@memory.load(4))
end

p Machine.new.run
