# Two libraries attach the same name at run time: a bare call reaches the
# one its scope includes (the latest include first), never the other's.
# spinel: share
require "ffi"
module Abs
  extend FFI::Library
  ffi_lib FFI::Library::LIBC
  def self.setup = [:abs].each { |n| attach_function :f, n, [:int], :int }
end
module Up
  extend FFI::Library
  ffi_lib FFI::Library::LIBC
  def self.setup = [:toupper].each { |n| attach_function :f, n, [:int], :int }
end
Abs.setup
Up.setup
class A
  include Abs
  def run = f(-7)
end
class U
  include Abs
  include Up
  def run = f(97)
end
p A.new.run, U.new.run
module Abs
  def self.again = f(-2)
end
p Abs.again
