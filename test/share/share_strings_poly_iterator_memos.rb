# spinel: gc-minor
# Numeric iterators can return a String memo even though their elements
# contain no Strings. An empty sum returns its initial value unchanged.
class MemoString
  def value = +"ab"
end
class MemoNumber
  def value = 7
end
objects = [MemoString.new, MemoNumber.new]
result = (1..1).inject(objects[0].value) { |memo, i| memo }
items = [result, result]
items[0] << "x"
p items
result = (1..2).reduce(objects[0].value) { |memo, i| memo << i.to_s; memo }
other = result
other << "y"
p result, other
result = (1..2).each_with_object(objects[0].value) { |i, memo| memo << i.to_s }
other = result
other << "z"
p result, other
result = 3.times.each_with_object(objects[0].value) { |i, memo| memo << "!" }
other = result
other << "?"
p result, other
result = (1..0).sum(objects[0].value)
other = result
other << "+"
p result, other
values = [1]
values.clear
result = values.sum(objects[0].value)
other = result
other << "-"
p result, other
