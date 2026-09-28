# Data is not Enumerable: each, each_pair, each_with_index, size and
# length are Struct's, and a Data instance raises NoMethodError for them.
D = Data.define(:x, :y)
d = D.new(x: 1, y: 2)

def try(label)
  yield
  p [label, :ran]
rescue NoMethodError => e
  p [label, e.class]
end

try(:each) { d.each { |v| p v } }
try(:each_pair) { d.each_pair { |k, v| p k } }
try(:each_pair_no_block) { d.each_pair }
try(:each_with_index) { d.each_with_index { |v, i| p i } }
try(:size) { p d.size }
try(:length) { p d.length }
try(:map) { p d.map { |v| v } }
p d.respond_to?(:each)

def walk(o) = o.each { |v| p v }
try(:param_each) { walk(d) }

S = Struct.new(:a, :b)
s = S.new(1, 2)
s.each { |v| p v }
s.each_pair { |k, v| p [k, v] }
p s.size
