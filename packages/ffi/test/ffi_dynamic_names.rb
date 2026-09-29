# Functions attached under names that come from data (a table walked in a
# method), called on the module and -- through include -- bare.
require "ffi"
module Dyn
  extend FFI::Library
  ffi_lib FFI::Library::LIBC
  def self.setup
    [[:abs, [:int], :int], [:labs, [:long], :long], [:strlen, [:string], :size_t]].each do |e|
      attach_function e[0], e[0], e[1], e[2]
    end
    attach_function :my_toupper, :toupper, [:int], :int
  end
end
Dyn.setup
p Dyn.abs(-3), Dyn.labs(-5), Dyn.strlen("four")
include Dyn
p abs(-9), my_toupper(97)
def helper = strlen("xyz")
p helper
begin
  Dyn.nope(1)
rescue NoMethodError => e
  puts "NoMethodError"
end
