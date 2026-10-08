# A callback type followed by a parameter Array is the return type, not
# the complete signature. A returned callback may be nil or another function.
require "ffi"

module Callbacks
  extend FFI::Library
  callback :result, [], :int
end

type = Callbacks.find_type(:result)
p FFI::Function.new(type, []) { nil }.call
result = FFI::Function.new(:int, []) { 7 }
fn = FFI::Function.new(type, []) { result }
p fn.call.call
arg = FFI::Function.new(type, [:int]) { |x| x > 0 ? result : nil }
p arg.call(0), arg.call(1).call
