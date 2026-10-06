# A Proc or lambda handed as a block argument to Array#index or #rindex, or
# to an element iterator over each_slice / each_cons (`a.each_slice(2).map
# (&pr)`), runs as a block literal does. The block-argument forward knew
# neither shape, and the call raised NoMethodError.
odd = proc { |x| x.odd? }
even = proc { |x| x.even? }
p [1, 2].index(&odd), [1, 2, 4].rindex(&even), [1, 2].find_index(&even)
p %w[a b].index(&->(s) { s == "b" }), [1.5, 2.5].index(&proc { |x| x > 2 })
p [1, 3].index(&even)
def first_match(&) = [1, 2, 3].index(&)
p first_match { |x| x == 3 }
p [3, 1].index(3), [1, 2].index { |x| x > 1 }
to_s = proc { |x| x.to_s }
sum = proc { |x| x.sum }
p [1, 2].each_slice(1).map(&to_s)
p [1, 2, 3].each_slice(2).map(&sum), [1, 2, 3].each_cons(2).map(&sum)
p [1, 2, 3].each_slice(2).select(&proc { |x| x.size > 1 })
p (1..4).each_slice(2).map(&->(a) { a.sum })
p [1, 2, 3, 4].each_slice(2).map(&proc { |a, b| a + b })
p({ a: 1, b: 2 }.each_slice(1).map(&proc { |x| x }))
