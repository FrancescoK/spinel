# `nested.each_with_index { }` where nested is first untyped, then an Array
# from `map.with_index`, beside a Struct (json_schemer's contains
# validator): the class arm the receiver test built answers what Array's
# own each_with_index answers.

R = Struct.new(:valid)

def validate(instance)
  return R.new(true) unless instance.is_a?(Array)
  nested = instance.map.with_index { |item, index| R.new(item > index) }
  annotation = []
  nested.each_with_index { |r, index| annotation << index if r.valid }
  annotation
end

p validate([3, 0, 5])
p validate(1)
