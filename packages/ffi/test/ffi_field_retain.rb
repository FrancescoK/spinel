# What a struct's pointer field holds (a MemoryPointer, a Struct) stays alive
# as long as the struct, and what an attached pointer variable holds as long
# as the variable, as with the gem. Only an array of chars takes a
# String's bytes.
require "ffi"

class Inner < FFI::Struct
  layout :name, :pointer
end
class Rec < FFI::Struct
  layout :name, :pointer, :inner, Inner, :ptrs, [:pointer, 2], :chars, [:char, 4], :ints, [:int, 2]
end

def churn
  i = 0
  junk = nil
  while i < 3000
    junk = "z" * 256
    i += 1
  end
  GC.start
  junk.size
end

module V
  extend FFI::Library
  ffi_lib FFI::Library::LIBC
  attach_variable :optarg_p, :optarg, :pointer
end

r = Rec.new
V.optarg_p = FFI::MemoryPointer.from_string("variable")
r[:name] = FFI::MemoryPointer.from_string("direct")
churn
churn
p r[:name].read_string, V.optarg_p.read_string
V.optarg_p = nil
r[:chars] = "abc"
p r[:chars].to_a
begin
  r[:ints] = "abcdefgh"
rescue NotImplementedError => e
  puts "NotImplementedError: #{e.message}"
end
