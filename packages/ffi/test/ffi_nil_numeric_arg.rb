# nil numeric arguments raise TypeError, but the ffi gem zeroes a callback's
# nil return after any DataConverter runs. Both paths use the same signature.
require "ffi"
require "bigdecimal"

module LibM
  extend FFI::Library
  ffi_lib FFI::Library::LIBC
  attach_function :abs, [:int], :int
  attach_function :labs, [:long], :long
end
module LibMath
  extend FFI::Library
  ffi_lib FFI::Library::CURRENT_PROCESS
  attach_function :fabs, [:double], :double
  attach_function :fabsf, [:float], :float
end

p LibM.abs(-3)
begin
  p LibM.abs(nil)
rescue TypeError => e
  puts "TypeError: #{e.message}"
end
begin
  p LibM.labs(nil)
rescue TypeError => e
  puts "TypeError: #{e.message}"
end
p LibMath.fabs(-2.5)
begin
  p LibMath.fabs(nil)
rescue TypeError => e
  puts "TypeError: #{e.message}"
end
begin
  p LibMath.fabsf(nil)
rescue TypeError => e
  puts "TypeError: #{e.message}"
end

cb = FFI::Function.new(:int, [:int]) { |x| x > 0 ? x : nil }
p cb.call(4)
begin
  p cb.call(-1)
rescue TypeError => e
  puts "TypeError: #{e.message}"
end
fcb = FFI::Function.new(:double, [:double]) { |x| x > 0 ? x : nil }
p fcb.call(1.5)
begin
  p fcb.call(-1.0)
rescue TypeError => e
  puts "TypeError: #{e.message}"
end

[:char, :uchar, :short, :ushort, :int, :uint, :long, :ulong,
 :long_long, :ulong_long, :float, :double].each do |type|
  puts type
  fn = FFI::Function.new(type, [type]) { |x| x > 0 ? x : nil }
  p fn.call(7), fn.call(0)
  begin
    fn.call(nil)
  rescue TypeError
    puts "nil argument: TypeError"
  end
end

p FFI::Function.new(:long_double, []) { nil }.call.to_f
p FFI::Function.new(:bool, []) { nil }.call
p FFI::Function.new(:bool, []) { true }.call
p FFI::Function.new(:bool, []) { false }.call
p FFI::Function.new(:pointer, []) { nil }.call.null?
p FFI::Function.new(:string, []) { nil }.call
strptr = FFI::Function.new(:strptr, []) { nil }.call
p strptr[0], strptr[1].null?
p FFI::Function.new(:void, []) { nil }.call

module Callbacks
  extend FFI::Library
  callback :result, [], :int
end
FFI.typedef(Callbacks.find_type(:result), :nil_callback_result)
p FFI::Function.new(:nil_callback_result, []) { nil }.call

class Result < FFI::Struct
  layout :i, :int, :d, :double
end
result = FFI::Function.new(Result.by_value, []) { nil }.call
p result[:i], result[:d]
p FFI::Function.new(Result.by_ref, []) { nil }.call.pointer.null?

module NilResult
  extend FFI::DataConverter
  native_type :int
  def self.to_native(value, context)
    puts "convert #{value.inspect}"
    nil
  end
  def self.from_native(value, context) = value
end
mapped = FFI.find_type(NilResult)
p FFI::Function.new(mapped, []) { :missing }.call
p FFI::Function.new(mapped, []) { nil }.call
begin
  FFI::Function.new(:int, [mapped]) { |x| x }.call(:missing)
rescue TypeError
  puts "converted nil argument: TypeError"
end
