# frozen_string_literal: true
require_relative 'types'

class TypesPlain; end
module TypesModule; end
class TypesError < StandardError; end
TypesStruct = Struct.new(:a)
TypesData = Data.define(:b)
class TypesArray < Array; end
values = [nil, true, false, 7, -3, 1.5, :symbol, "text", "text".dup, [1, 2], [1, "a"], {"a" => 1}, {a: 1},
          TypesPlain, TypesModule, TypesPlain.new, TypesError.new("x"), 1..2, /re/, 1.5..2.5,
          "abc".match(/b/), proc { 1 }, Time.at(0), TypesStruct.new(1), TypesData.new(b: 2), TypesArray.new]
values.each do |value|
  p [value.class, CextTypes.type_of(value), CextTypes.hash?(value)]
end
p CextTypes.check_hash({"a" => 1})
p CextTypes.check_array([3])
[nil, true, 1, "s", [1], :s, 1.5, TypesPlain.new].each do |value|
  CextTypes.check_hash(value)
rescue TypeError => e
  p e.message
end
begin
  CextTypes.check_array({})
rescue TypeError => e
  p e.message
end
