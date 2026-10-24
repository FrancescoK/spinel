# spinel: not-cruby -- FFI::Native is the ffi package's own binding module.
# A native_func's :float argument reached through the module held as a
# value (the def that stands for it, native_twin_def) with a value of any
# representation: a boxed Float or Integer is converted to the double the
# C function takes, nil raises TypeError, as at a call on the constant.
require "ffi"

def put(m, addr, v) = m.put_float(addr, FFI::Type::K_F64, v)
def get(m, addr) = m.get_float(addr, FFI::Type::K_F64)

n = FFI::Native
mem = FFI::MemoryPointer.new(:double, 1)
[2.5, 3, 0.125].each do |v|
  put(n, mem.address, v)
  p get(n, mem.address)
end
begin
  put(n, mem.address, [nil, 1][0])
rescue TypeError => e
  puts e.message
end
