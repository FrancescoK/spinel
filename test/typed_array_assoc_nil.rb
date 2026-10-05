# assoc and rassoc on an Array of numbers, Strings, Symbols or booleans find
# no Array element to match and answer nil, after evaluating the receiver
# and the key, as CRuby does; arrays of arrays keep matching.
$log = []
def t(x)
  $log << x
  x
end
a = [3, 1, 2]
p a.assoc(1), a.rassoc(1), ["a", "b"].assoc("a"), [1.5, 2.5].assoc(1.5)
p [:a, :b].assoc(:a), [true, false].rassoc(false)
x = a.assoc(3)
p x, x.nil?, x.class
puts "miss" unless a.assoc(1)
p t(a).assoc(t(2)), $log
p [[1, 2], [3, 4]].assoc(3), [[1, 2]].rassoc(2), [[1, :a], 5].assoc(1)
