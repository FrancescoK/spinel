# A bitmask maps nil to no flags before native argument or return conversion.
# An enum still rejects nil; mapped conversions run before callback zeroing.
require "ffi"

module Flags
  extend FFI::Library
  bitmask :access, [:read, :write]
  enum :result, [:zero, 0, :one, 1]
end

mask = Flags.find_type(:access)
fn = FFI::Function.new(mask, [mask]) { |flags| flags.empty? ? nil : flags }
p fn.call(nil), fn.call([]), fn.call([:read]), fn.call([:read, :write])
p FFI::Function.new(mask, []) { nil }.call

enum = Flags.find_type(:result)
begin
  FFI::Function.new(enum, []) { nil }.call
rescue ArgumentError => e
  puts "ArgumentError: #{e.message}"
end
p FFI::Function.new(enum, []) { :one }.call
