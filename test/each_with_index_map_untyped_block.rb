# each_with_index yields the element and its index as two values, and a
# Symbol block sends to the element with the index as its argument, from a
# literal `&:m` or a Symbol held in a local. A block value no class answers
# (String#first) is carried boxed by each_with_index.map / select / reject
# and by Array#select / reject, and raises the NoMethodError CRuby does.

def try
  p yield
rescue NoMethodError, ArgumentError => e
  p [e.class, e.message]
end

try { ["a", "b"].each_with_index.map(&:first) }
try { ["a", "b"].each_with_index.map(&:upcase) }
try { [[1, 2]].each_with_index.map(&:first) }
try { [[1, 2], [3]].each_with_index.map(&:push) }
try { [1, 2].each_with_index.map(&:+) }

s = "first".to_sym
try { ["a", "b"].each_with_index.map(&s) }
try { [[1, 2]].each_with_index.map(&s) }
u = "upcase".to_sym
try { ["a", "b"].each_with_index.map(&u) }
w = "push".to_sym
try { [[1, 2], [3]].each_with_index.map(&w) }
try { [[1, 2]].map.with_index(&w) }
try { [[1, 2]].each_with_index.each(&w) }

try { ["a", "b"].each_with_index.map { |x, i| x.first(i) } }
try { ["a", "b"].each_with_index.map { |x, i| x.first } }
try { [1].each_with_index.map { |x, i| x.first } }
try { ["a"].each.with_index.map { |x, i| x.first } }
try { ["a"].each_with_index.select { |x, i| x.first } }
try { ["a"].each_with_index.reject { |x, i| x.first } }
try { ["a"].select { |x| x.first } }
try { ["a"].reject { |x| x.first } }
try { [].select { |x| x.first } }
try { [].each_with_index.map { |x, i| x.first } }
