# Range copies preserve endpoints but have their own frozen state.

puts "integer"
integer = (1..2)
p integer.frozen?
p integer.dup.frozen?
p integer.clone.frozen?
p integer.clone(freeze: false).frozen?
p integer.clone(freeze: true).frozen?
p integer.dup.clone(freeze: nil).frozen?
p integer.dup.clone.frozen?
p integer.dup.clone(freeze: true).frozen?
p integer.dup == integer
p integer.frozen?

puts "float"
float = (1.0...2.5)
p float.frozen?
p float.dup.frozen?
p float.clone.frozen?
p float.clone(freeze: false).frozen?
p float.clone(freeze: true).frozen?
p float.dup.clone(freeze: nil).frozen?
p float.dup.clone.frozen?
p float.dup.clone(freeze: true).frozen?
p float.dup == float
p float.frozen?

puts "endless"
endless = (1..)
p endless.frozen?
p endless.dup.frozen?
p endless.clone.frozen?
p endless.clone(freeze: false).frozen?
p endless.clone(freeze: true).frozen?
p endless.dup.clone(freeze: nil).frozen?
p endless.dup.clone.frozen?
p endless.dup.clone(freeze: true).frozen?
p endless.dup == endless
p endless.frozen?

puts "beginless"
beginless = (..2)
p beginless.frozen?
p beginless.dup.frozen?
p beginless.clone.frozen?
p beginless.clone(freeze: false).frozen?
p beginless.clone(freeze: true).frozen?
p beginless.dup.clone(freeze: nil).frozen?
p beginless.dup.clone.frozen?
p beginless.dup.clone(freeze: true).frozen?
p beginless.dup == beginless
p beginless.frozen?

puts "string"
string = ("a".."c")
p string.frozen?
p string.dup.frozen?
p string.clone.frozen?
p string.clone(freeze: false).frozen?
p string.clone(freeze: true).frozen?
p string.dup.clone(freeze: nil).frozen?
p string.dup.clone.frozen?
p string.dup.clone(freeze: true).frozen?
p string.dup == string
p string.frozen?

puts "new_integer"
new_integer = (Range.new(1, 2))
p new_integer.frozen?
p new_integer.dup.frozen?
p new_integer.clone.frozen?
p new_integer.clone(freeze: false).frozen?
p new_integer.clone(freeze: true).frozen?
p new_integer.dup.clone(freeze: nil).frozen?
p new_integer.dup.clone.frozen?
p new_integer.dup.clone(freeze: true).frozen?
p new_integer.dup == new_integer
p new_integer.frozen?

puts "new_float"
new_float = (Range.new(1.0, 2.5))
p new_float.frozen?
p new_float.dup.frozen?
p new_float.clone.frozen?
p new_float.clone(freeze: false).frozen?
p new_float.clone(freeze: true).frozen?
p new_float.dup.clone(freeze: nil).frozen?
p new_float.dup.clone.frozen?
p new_float.dup.clone(freeze: true).frozen?
p new_float.dup == new_float
p new_float.frozen?

puts "new_endless"
new_endless = (Range.new(1, nil))
p new_endless.frozen?
p new_endless.dup.frozen?
p new_endless.clone.frozen?
p new_endless.clone(freeze: false).frozen?
p new_endless.clone(freeze: true).frozen?
p new_endless.dup.clone(freeze: nil).frozen?
p new_endless.dup.clone.frozen?
p new_endless.dup.clone(freeze: true).frozen?
p new_endless.dup == new_endless
p new_endless.frozen?

puts "new_beginless"
new_beginless = (Range.new(nil, 2))
p new_beginless.frozen?
p new_beginless.dup.frozen?
p new_beginless.clone.frozen?
p new_beginless.clone(freeze: false).frozen?
p new_beginless.clone(freeze: true).frozen?
p new_beginless.dup.clone(freeze: nil).frozen?
p new_beginless.dup.clone.frozen?
p new_beginless.dup.clone(freeze: true).frozen?
p new_beginless.dup == new_beginless
p new_beginless.frozen?

puts "new_string"
new_string = (Range.new("a", "c"))
p new_string.frozen?
p new_string.dup.frozen?
p new_string.clone.frozen?
p new_string.clone(freeze: false).frozen?
p new_string.clone(freeze: true).frozen?
p new_string.dup.clone(freeze: nil).frozen?
p new_string.dup.clone.frozen?
p new_string.dup.clone(freeze: true).frozen?
p new_string.dup == new_string
p new_string.frozen?

puts "boxed"
values = [0, (1..2), (1.0...2.5), (1..), (..2), ("a".."c"), Range.new(1, 2)]
values.each do |r|
  if r.is_a?(Range)
    p r.frozen?
    p r.dup.frozen?
    p r.clone.frozen?
    p r.clone(freeze: false).frozen?
    p r.clone(freeze: true).frozen?
    p r.dup.clone(freeze: nil).frozen?
    p r.dup.clone.frozen?
    p r.dup.clone(freeze: true).frozen?
    p r.dup == r
    p r.frozen?
  end
end

# Boxing a copy retains its state; freezing a boxed copy leaves its source alone.
puts "boxed copies"
copies = [0, integer.dup, float.dup, endless.dup, beginless.dup, string.dup]
copies.each do |copy|
  if copy.is_a?(Range)
    p copy.frozen?
    frozen_copy = copy.clone(freeze: true)
    p frozen_copy.frozen?
    p copy.frozen?
    copy.freeze
    p copy.frozen?
  end
end

puts "typed freeze"
integer_copy = integer.dup
integer_copy.freeze
p integer_copy.frozen?
float_copy = float.dup
float_copy.freeze
p float_copy.frozen?
string_copy = string.dup
string_copy.freeze
p string_copy.frozen?

# Copying or freezing must not change the flags beside the frozen state.
puts "range flags"
flagged = [0, (1...2.5), (1.5..3), (1.5...3), (...2.5), (1.5...), ("a"..."d")]
flagged.each do |r|
  if r.is_a?(Range)
    copy = r.dup
    p copy.frozen?
    p copy.inspect
    p copy.exclude_end?
    copy.freeze
    p copy.frozen?
    p copy.inspect
  end
end
