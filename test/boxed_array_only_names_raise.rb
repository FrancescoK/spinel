# Array's own product, combination, permutation, map!, collect! and
# each_index on a boxed Hash or Range: neither class has them, and CRuby
# raises NoMethodError, where the receiver was read as its elements (a
# Hash's pairs, a Range's members) and the call answered. A boxed String
# raises naming the method called (collect! was named map!), and an Array
# answers as before.

def t
  p yield
rescue NoMethodError => e
  puts e.message
end

k = ARGV.size
[{a: 1}, 1..3, "sa", [1, 2]].each do |v|
  n = [v, 0][k]
  t { n.product([1]) }
  t { n.combination(1).to_a }
  t { n.permutation(1).to_a }
  t { n.map! { |y| y } }
  t { n.collect! { |y| y } }
  t { n.each_index { } }
end
