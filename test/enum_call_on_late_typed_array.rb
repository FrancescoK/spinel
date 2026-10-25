# An Enumerable call on an Array the analysis types only after its main
# pass: a method answering a local assigned only `[]`, with no push that
# says what it holds, is given an Array there. The calls on its answer were
# never rewritten onto their builtins/enumerable.rb copies, and each one
# raised NoMethodError for a method every Array has.
def none_yet
  out = []
  out
end

p none_yet.drop_while { |x| x }
p none_yet.take_while { |x| x }
p none_yet.each_with_object([]) { |x, acc| acc << x }
p none_yet.find_index { |x| x }
p none_yet.flat_map { |x| [x] }
p none_yet.min_by { |x| x }
p none_yet.group_by { |x| x }
p none_yet.partition { |x| x }
p none_yet.filter_map { |x| x }
p none_yet.tally
p none_yet.count { |x| x }
p none_yet.select { |x| x }
p none_yet.map(&:to_s)
# a block the program writes with a parameter named like the parser's
# `&:m` one is still a block of its own
p none_yet.drop_while { |_spx| _spx + 1 }
