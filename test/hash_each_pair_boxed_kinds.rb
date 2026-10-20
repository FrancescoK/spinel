# `each { |k, v| }` and each_pair over a boxed value bind a builtin Hash's key
# and value without building a [k, v] pair, for every Hash kind; a boxed
# Array of pairs (and a non-pair element) still splats as before, a third
# parameter binds nil, and a break leaves the walk.
def walk(x)
  out = []
  x.each { |k, v| out << [k, v] }
  out
end

def walk3(x)
  out = []
  x.each_pair { |k, v, extra| out << [k, v, extra] }
  out
end

values = [
  { "a" => 1, "b" => 2 },
  { "a" => "x", "b" => "y" },
  { 1 => "x", 2 => "y" },
  { 1 => 10, 2 => 20 },
  { "a" => 1, "b" => "two", "c" => nil, "d" => [3] },
  { a: 1, b: "two" },
  { 1 => "one", "two" => 2, nil => :sym },
  {},
  [[1, 2], [3, 4], 5],
  "not iterable"
]
values.each do |x|
  next unless x.respond_to?(:each)
  p walk(x)
end
p walk3(values[4])

firsts = []
values[0].each do |k, v|
  firsts << k
  break if v == 1
end
p firsts
