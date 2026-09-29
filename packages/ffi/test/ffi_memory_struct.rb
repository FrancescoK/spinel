# FFI::MemoryPointer / Pointer accessors, Struct layouts (nested, arrays,
# unions, explicit offsets), callbacks stored in struct fields, and
# ObjectSpace finalizers on FFI-owned objects.
require "ffi"

mp = FFI::MemoryPointer.new(:uint8, 16)
mp.put_uint32(0, 0xdeadbeef)
mp.put_int16(4, -2)
mp.put_float(8, 1.5)
p mp.get_uint32(0).to_s(16), mp.get_int16(4), mp.get_float(8), mp.size
p mp.get_bytes(0, 4).bytesize
mp.put_bytes(12, "abcd")
p mp.get_string(12, 4)
d = FFI::MemoryPointer.new(:double, 3)
d.write_array_of_double([1.25, 2.5, 3.75])
p d.read_array_of_double(3), (d + 8).read_double
s = FFI::MemoryPointer.from_string("hello")
p s.read_string, s.size
begin
  mp.get_int64(12)
rescue IndexError => e
  puts "IndexError"
end
p FFI::Pointer::NULL.null?, FFI::Pointer.new(0) == nil

class Point < FFI::Struct
  layout :x, :int32, :y, :int32
end
class Rect < FFI::Struct
  layout :origin, Point, :size, Point, :tag, [:char, 8], :vals, [:int16, 3]
end
r = Rect.new
r[:origin][:x] = 3
r[:origin][:y] = 4
r[:size][:x] = 10
r[:tag] = "box"
r[:vals][1] = 42
p Rect.size, Rect.offset_of(:size), Rect.offset_of(:tag), Rect.members
p r[:origin][:x] + r[:origin][:y], r[:size][:x], r[:tag].to_s, r[:vals].to_a

class U < FFI::Union
  layout :i, :uint32, :f, :float
end
u = U.new
u[:f] = 1.0
p U.size, u[:i].to_s(16)

class Packed < FFI::Struct
  layout :a, :uint8, 0, :b, :uint32, 4, :c, :uint8, 8
end
p Packed.size, Packed.offset_of(:c)

module L
  extend FFI::Library
  ffi_lib FFI::Library::LIBC
  attach_function :dlsym, [:pointer, :string], :pointer
  class Vt < FFI::Struct
    layout :abs, callback([:int], :int), :labs, callback([:long], :long)
  end
end
vt = L::Vt.new
self_lib = FFI::DynamicLibrary.open(nil, FFI::DynamicLibrary::RTLD_LAZY)
vt[:abs] = FFI::Function.new(:int, [:int], self_lib.find_function("abs"))
vt[:labs] = FFI::Function.new(:long, [:long], self_lib.find_function("labs"))
p vt[:abs].call(-7), vt[:labs].call(-12345678901)

add = FFI::Function.new(:int, [:int, :int]) { |a, b| a + b }
fwd = FFI::Function.new(:int, [:int, :int], add.to_ptr)
p fwd.call(20, 22)

puts "done"
