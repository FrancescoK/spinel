# A method polls at its entry for a delivered signal (#9222) when it makes
# a call that may reach any method, here a proc's call: a cycle through that
# call enters the method again. Bus#read only reaches such a method and
# does not poll. Bus#sum calls a method that yields and makes such a call;
# that body runs spliced into Bus#sum, which polls.
class Device
  def initialize(&blk) = @blk = blk
  def peek(addr) = @blk.call(addr)
  def each_byte(addr)
    yield @blk.call(addr)
  end
end

class Bus
  def initialize(dev) = @dev = dev
  def read(addr) = @dev.peek(addr) + 1

  def sum(addr)
    s = 0
    @dev.each_byte(addr) { |b| s += b }
    s
  end
end

bus = Bus.new(Device.new { |a| a * 2 })
p bus.read(20)
p bus.sum(3)
