# A boolean stored through `[]=` on a boxed receiver, where a user class
# declares `[]=` with an Integer value: that class's arm cannot take the
# boolean, so the dispatch skips it instead of handing an sp_bool to its
# integer slot.

class Memory
  def initialize
    @bytes = Array.new(4, 0)
  end

  #: (Integer, Integer?) -> void
  def []=(addr, value)
    @bytes[addr] = value || 0
  end

  def [](addr) = @bytes[addr]
end

memory = Memory.new
memory[1] = 5
memory[2] = nil
p memory[1]
p memory[2]

slots = [memory, [false, false, false], {}]
border = slots[1]
border[1] = !border[0]
p border
read = slots[2]
read["key"] = true
p read
memory = slots[0]
memory[3] = 7
p memory[3]
