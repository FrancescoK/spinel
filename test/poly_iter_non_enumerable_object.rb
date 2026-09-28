# A boxed object whose class has no #each reaching a builtin iteration
# (each, map, any?, ...) raises NoMethodError; it is not walked as an
# empty container.
class Foo; end
D = Data.define(:x, :y)

def try(label)
  r = yield
  p [label, r]
rescue NoMethodError => e
  p [label, e.class]
end

[Foo.new, D.new(x: 1, y: 2), [3, 4]].each do |x|
  try(:each) { x.each { |v| p v } }
  try(:map) { x.map { |v| v } }
  try(:any?) { x.any? }
  try(:count) { x.count { |v| v } }
  try(:each_with_index) { x.each_with_index { |v, i| p i } }
  try(:reverse_each) { x.reverse_each { |v| p v } }
end
