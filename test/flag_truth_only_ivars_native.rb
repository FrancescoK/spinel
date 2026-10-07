# spinel: int64 -- the pointers' addresses are 64-bit Integers
# An ivar read only for its truthiness still holds the object written into
# it in a program that links native code: an FFI pointer owns memory that
# native code addresses, and the ivar may be what keeps it alive.
require "ffi"

class Frame
  def initialize = (@buf = false; @mem = nil)
  def inspect = "Frame"
  def attach(n)
    @buf ||= FFI::MemoryPointer.new(:int32, n)
    @mem = FFI::MemoryPointer.new(:int32, n)
    nil
  end
  def ready? = @buf ? 1 : 0
end

f = Frame.new
p f.ready?
f.attach(4)
p f.ready?
