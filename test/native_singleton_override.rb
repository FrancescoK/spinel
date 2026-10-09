# spinel: share
# spinel: gc-minor
# Ruby singleton methods replace native and FFI functions, including their types.
require "json"
require "base64"
require "stringio"
module JSON
  def self.parse(text) = { "user" => text }
  def self.generate(value) = "generate:#{value}"
  def self.dump(value) = value + 10
end
module Base64
  def self.encode64(text) = text.size + 20
end
class StringIO
  def self.new(*args) = "stringio:#{args.size}"
end
module NativeOverride
  # CRuby can read the FFI declaration; the call below uses the Ruby method.
  def self.ffi_func(*) = nil
  ffi_func :abs, [:int], :int
  def self.abs(value) = "abs:#{value}"
end
p JSON.parse("input")
p JSON.generate(2)
p JSON.dump(3)
p Base64.encode64("hello")
p NativeOverride.abs(-4)
p StringIO.new("input")
