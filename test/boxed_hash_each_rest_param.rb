# A block whose only parameter is a rest parameter binds the whole entry of
# a Hash read out of a mixed value: `each { |*r| }` sees [[key, value]].
def sym_or_ary(f) = f ? {abc: 10, zz: "x"} : [1, 2, 3]
def str_or_ary(f) = f ? {"abc" => 10, "zz" => "x"} : [1, 2, 3]
def int_or_ary(f) = f ? {1 => 10, "zz" => "x"} : [1, 2, 3]

sym_or_ary(true).each { |*r| p r }
str_or_ary(true).each { |*r| p r }
int_or_ary(true).each { |*r| p r }
sym_or_ary(false).each { |*r| p r }
sym_or_ary(true).each_pair { |*r| p r }
sym_or_ary(true).each_with_index { |*r| p r }
p sym_or_ary(true).map { |*r| r }

h = sym_or_ary(true)
h.each { |*r| p r.size }
h.each { |*r| p r.first.class }
acc = []
h.each { |*r| acc << r }
p acc
h.each { |*r| break p(r) }

# each_entry and reverse_each, Integer keys, and an Enumerator that yields several values a step
sym_or_ary(true).each_entry { |*r| p r }
sym_or_ary(true).reverse_each { |*r| p r }
def int2_or_ary(f) = f ? {1 => "a", 2 => "b"} : [1, 2, 3]
p int2_or_ary(true).map { |*r| r }
int2_or_ary(true).each { |*r| p r }
def steps(f) = f ? Enumerator.new { |y| y.yield 1, 2; y.yield 3; y.yield } : [1]
steps(true).each { |*r| p r }
p steps(true).map { |*r| r }

# a Hash the compiler types keeps working
{a: 1}.each { |*r| p r }
{"q" => 1}.each { |*r| p r }
