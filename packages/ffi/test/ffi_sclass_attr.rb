# singleton attr_accessor on an FFI::Library module is a method, not a foreign call
require "ffi"
module GLib
  class << self
    attr_accessor :logger
  end
  @logger = "LOG"
  extend FFI::Library
  ffi_lib FFI::Library::LIBC
  attach_function :strlen, [:string], :size_t
  def self.go; p logger; end
end
GLib.go
p GLib.logger
GLib.logger = "x"
p GLib.logger
