# Method objects of attached functions, passed around and called later (the
# ffi-libarchive shape: super C.method(:archive_read_new), ...).
require "ffi"
module Arch
  module C
    extend FFI::Library
    ffi_lib FFI::Library::LIBC
    attach_function :getpid, [], :int
    attach_function :getppid, [], :int
    attach_function :abs, [:int], :int
    attach_function :labs, [:long], :long
  end
  class Base
    def initialize(alloc, free)
      @archive = alloc.call
      @free = [nil]
      @free[0] = free
    end
    def close = @free[0].call(-@archive)
  end
  class Reader < Base
    def initialize(params = {})
      super C.method(:getpid), C.method(:abs)
    end
  end
  class Writer < Base
    def initialize(params = {})
      super C.method(:getppid), C.method(:labs)
    end
  end
end
p Arch::Reader.new.close > 0
p Arch::Writer.new.close > 0
