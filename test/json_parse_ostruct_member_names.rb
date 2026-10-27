# An OpenStruct's member named like a builtin method (size, first, max,
# last, sum, upcase) reads the member on a boxed receiver that may be an
# OpenStruct, beside an Array or a String: the receiver's dispatch answered
# the containers' size 0, first nil or max NoMethodError for it. That holds
# for JSON.parse(s, object_class: OpenStruct), which makes every object of
# the document an OpenStruct: on the document, a nested object, an object
# inside an Array and a member that is itself an OpenStruct.
require "json"
require "ostruct"

[OpenStruct.new(size: 9, first: "a", max: 4), [3, 1, 2]].each do |x|
  p [x.size, x.first, x.max]
end
[OpenStruct.new(upcase: :member), "abc"].each { |x| p x.upcase }

doc = JSON.parse('{"size": 9, "first": "a", "max": 4, "limits": {"last": 2}, "rows": [{"min": 1}]}', object_class: OpenStruct)
p doc.size, doc.first, doc.max
p doc.limits.last
p doc.rows[0].min
p doc.rows.size

list = JSON.parse('[{"sum": 5}, {"sum": 6}]', object_class: OpenStruct)
p list[0].sum
p list.size
p list.map(&:sum)

nested = JSON.parse('{"size": {"max": 7}}', object_class: OpenStruct)
p nested.size.max
p [OpenStruct.new(size: OpenStruct.new(max: 9)), [1, 2]].first.size.max
