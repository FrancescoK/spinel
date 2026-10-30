# MemoryPointer.new with a block yields the new pointer to it, as the ffi
# gem does (prism fills its buffers inside such a block); new still answers
# the pointer, and the block runs with the self of its home. The gem frees
# the memory when the block returns, so the bytes are read inside it.
require "ffi"

class Buffer
  def self.with
    result = nil
    FFI::MemoryPointer.new(:int32, 2) do |pointer|
      p self
      pointer.put_int32(0, 7)
      pointer.put_int32(4, 9)
      result = yield pointer
    end
    result
  end
end

p Buffer.with { |ptr| [ptr.get_int32(0), ptr.get_int32(4)] }

mp = FFI::MemoryPointer.new(8) do |ptr|
  ptr.put_bytes(0, "abc")
  p ptr.get_bytes(0, 3)
end
p mp.class, mp.size

ran = false
FFI::MemoryPointer.new(:char, 1) { ran = true }
p ran
p FFI::MemoryPointer.new(:char, 1).size
