# A class that extends FFI::Library and a macro module: the library's own
# class-body calls (ffi_lib, attach_function) are the runtime, not macros, and
# do not stop the macro calls after them from being expanded.
require "ffi"

module Forwarders
  def forward(name, target, types)
    module_eval <<-RUBY, __FILE__, __LINE__ + 1
    def self.#{name}(*a) = [#{types.inspect}, #{target}(*a)]
    RUBY
  end
end

class Libc
  extend FFI::Library
  extend Forwarders
  ffi_lib FFI::Library::LIBC
  attach_function :labs, [:long], :long
  forward :labs_typed, :labs, %i[long]
end

p Libc.labs_typed(-5)
