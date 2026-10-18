require "monitor"

class WidenedBlock
  State = Struct.new(:monitor)

  def self.synchronize(id, &block)
    state = State.new(Monitor.new)
    state.monitor.synchronize { block.call(id) }
  end

  def save
    self.class.synchronize(3) { |id| id + 1 }
  end
end

def build_for_block(value, arg)
  value.new(arg)
end

p build_for_block(String, "abc")
p WidenedBlock.new.save
