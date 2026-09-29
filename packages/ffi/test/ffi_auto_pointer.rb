# FFI::AutoPointer runs its releaser once: on #free, or when the pointer is
# collected (at the latest at the end of the program) -- never with
# autorelease off.
require "ffi"

REL = proc { |ptr| puts "released #{ptr.address}" }

a = FFI::AutoPointer.new(FFI::Pointer.new(1), REL)
a.free
a.free
p a.autorelease?

b = FFI::AutoPointer.new(FFI::Pointer.new(2), REL)
b.autorelease = false
p b.autorelease?
b = nil

def dropped = FFI::AutoPointer.new(FFI::Pointer.new(3), REL).address
p dropped
GC.start
