# The ffi gem API over libc: callbacks (block and proc), varargs, out
# pointers, structs by reference, enums, typedefs and NotFoundError.
require "ffi"

module LibC
  extend FFI::Library
  ffi_lib FFI::Library::LIBC
  typedef :pointer, :buf
  callback :qsort_cmp, [:pointer, :pointer], :int
  attach_function :qsort, [:pointer, :size_t, :size_t, :qsort_cmp], :void
  attach_function :strlen, [:string], :size_t
  attach_function :getenv, [:string], :string
  attach_function :snprintf, [:buf, :size_t, :string, :varargs], :int
  attach_function :strtol, [:string, :pointer, :int], :long
  attach_function :div, [:int, :int], :int rescue nil
  begin
    attach_function :no_such_function_xyz, [], :int
  rescue FFI::NotFoundError => e
    puts "not found: #{e.message[0, 40]}"
  end

  class Timeval < FFI::Struct
    layout :tv_sec, :long, :tv_usec, :int
  end
  attach_function :gettimeofday, [Timeval.by_ref, :pointer], :int
end

arr = [5, 3, 9, 1, 7]
mp = FFI::MemoryPointer.new(:int32, arr.size)
mp.write_array_of_int32(arr)
LibC.qsort(mp, arr.size, 4) do |a, b|
  a.read_int32 <=> b.read_int32
end
p mp.read_array_of_int32(arr.size)

cmp = proc { |a, b| b.read_int32 <=> a.read_int32 }
LibC.qsort(mp, arr.size, 4, cmp)
p mp.read_array_of_int32(arr.size)

p LibC.strlen("hello world")
p LibC.getenv("HOME").nil?
p LibC.getenv("NO_SUCH_VAR_XYZ")

buf = FFI::MemoryPointer.new(:char, 64)
n = LibC.snprintf(buf, 64, "%d-%s-%.2f", :int, 42, :string, "abc", :double, 3.14159)
p n, buf.read_string

endp = FFI::MemoryPointer.new(:pointer)
p LibC.strtol("123xyz", endp, 10)
p endp.read_pointer.read_string

tv = LibC::Timeval.new
p LibC.gettimeofday(tv, nil)
p tv[:tv_sec] > 1_000_000_000
p LibC::Timeval.size, LibC::Timeval.members

Color = FFI::Enum.new([:red, :green, 5, :blue])
p Color[:blue], Color[0], Color.symbols
# a variadic signature reused, a read clamped to its buffer
buf = FFI::MemoryPointer.new(:char, 32)
3.times { |i| LibC.snprintf(buf, 32, "%d-%s", :int, i, :string, "x") }
p buf.read_string
begin
  FFI::MemoryPointer.from_string("abc").get_string(0, 100)
rescue IndexError
  p :out_of_bounds
end
p FFI::MemoryPointer.from_string("abc").get_string(0, 2)
