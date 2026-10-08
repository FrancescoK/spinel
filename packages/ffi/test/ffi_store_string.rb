# A Ruby String is not stored into native memory (nothing would keep it
# alive after the store): put, put_pointer, :string fields, inline arrays and
# attached variables refuse it, as the gem does. A call's argument is fine.
# spinel: share
require "ffi"

class Names < FFI::Struct
  layout :first, :string, :rest, [:string, 2], :ptr, :pointer
end
module L
  extend FFI::Library
  ffi_lib FFI::Library::LIBC
  attach_function :strlen, [:string], :size_t
  attach_function :puts, [:pointer], :int
end

def try(label)
  yield
  puts "#{label}: ok"
rescue ArgumentError, TypeError => e
  puts "#{label}: #{e.class}: #{e.message}"
end

mp = FFI::MemoryPointer.new(:pointer, 4)
n = Names.new
try("put :string") { mp.put(:string, 0, "x") }
try("put_pointer") { mp.put_pointer(8, "x") }
try("write_array_of_pointer") { mp.write_array_of_pointer(["a"]) }
try("struct :string") { n[:first] = "x" }
try("inline [:string]") { n[:rest][0] = "x" }
try("struct :pointer") { n[:ptr] = "x" }
try("Struct.new(String)") { Names.new("x" * 64) }
try("struct :string nil") { n[:first] = nil }
buf = FFI::MemoryPointer.new(:char, 8)
buf.write_array_of_type(:string, :put_string, ["ab"])
p buf.read_string
p L.strlen("four")
$stdout.flush
L.puts("arg")
