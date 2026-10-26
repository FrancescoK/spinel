# frozen_string_literal: true
require_relative 'conversions'

module Outer
  class Inner; end
end
class Pathy
  def to_str = "from to_str"
end

p CextConv.numbers(42)
p CextConv.numbers(-3)
p CextConv.numbers(2.75)
[0, 1, -1, 2**40, -(2**40), 2**62, 2**63, -(2**63), 2**64 + 5].each { |n| p [n, CextConv.pack(n)] }
begin
  CextConv.numbers("x")
rescue TypeError => e
  p e.message
end
begin
  CextConv.numbers(nil)
rescue TypeError => e
  p e.message
end
s = +"mutable"
p CextConv.freeze_it(s).frozen?
p CextConv.freeze_it([1, 2]).frozen?
p CextConv.class_by_path("Outer::Inner")
p CextConv.class_by_path("String")
a = [1, "two", 3, "two"]
p CextConv.delete_from(a, "two")
p a
p CextConv.delete_from(a, "none")
p CextConv.sym_name(:hello)
p CextConv.plus("foo", "bar")
p CextConv.plus("x".b, "y").encoding
p CextConv.arity_of(proc { |a, b| })
p CextConv.arity_of(lambda { |a, *b| })
p CextConv.arity_of(proc { })
p CextConv.as_string("plain")
p CextConv.as_string(Pathy.new)
begin
  CextConv.as_string(12)
rescue TypeError => e
  p e.message
end
r = CextConv.encodings("plain")
p r[0..5]
p [r[6], r[6].encoding, r[6].valid_encoding?]
p [r[7], r[7].encoding]
p [r[8], r[8].encoding]
p [r[9], r[9].frozen?, r[9].encoding]
p [r[10], r[10].encoding]
p CextConv.encodings("bin".b)[0..3]
begin
  CextConv.encodings("\xff".b)
rescue Encoding::UndefinedConversionError => e
  p e.class
end
p CextConv.allocs
