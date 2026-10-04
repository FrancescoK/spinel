# String#slice! statement forms, literal-splat expansion, each_codepoint
# enumerator, hash comparator min/max, Hash#flat_map single-param pair,
# chunk/slice enumerator chains (each/select/reject/flat_map),
# &:sym.to_proc as a block argument, and lazy take(n).force.
s = +"hello"
s.slice!(0)
puts s
s = +"hello"
s.slice!(1..2)
puts s
s = +"hello"
s.slice!(99)
puts s
p [1, 2, 3].min(*[2])
p [1, 2, 3].first(*[2])
add = ->(a, b) { a + b }
p add.(*[3, 4])
p "abc".each_codepoint.to_a
h = { a: 1, b: 3, c: 2 }
p h.min { |x, y| x[1] <=> y[1] }
p h.max { |x, y| x[1] <=> y[1] }
p h.minmax { |x, y| x[1] <=> y[1] }
p({ a: [1, 2], b: [3, 4] }.flat_map { |pair| pair[1] })
p({ a: 1, b: 2 }.flat_map { |k, v| [k, v] })
[1, 1, 2, 3].chunk { |x| x }.each { |k, v| p [k, v] }
p [1, 2, 3, 4].each_slice(2).select { |sl| sl.sum > 3 }
p [1, 2, 3, 4].each_slice(2).reject { |sl| sl.sum > 3 }
p [1, 2, 3, 4].each_cons(2).flat_map { |sl| sl }
p ["a", "b"].map(&:upcase.to_proc)
p [1, 2, 3, 4, 5, 6].lazy.map { |x| x * 2 }.take(3).force
p (1..Float::INFINITY).lazy.map { |x| x * x }.take(3).force
