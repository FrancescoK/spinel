# difference, union and intersection on an Array held in a mixed Array (a
# boxed receiver) answer as on an Array, over one or more arguments and
# leaving the receiver alone; another kind of value raises NoMethodError.
s = [[3, 1, 2, 1], "x"][0]
p s.difference([1]), s.difference([1], [2]), s.difference([])
p s.union([9]), s.union([9], [3, 8]), s.union([1.0])
p s.intersection([1, 3]), s.intersection([1, 3], [3]), s.intersection([[1]])
p s
n = [5, [1]][0]
begin
  n.union([1])
rescue NoMethodError => e
  puts e.message
end
