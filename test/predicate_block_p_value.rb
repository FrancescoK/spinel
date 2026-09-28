# A predicate iterator whose block ends in `p x` reads p's return value
# (its argument, or the argument array) as the block's truthiness.
h = {x: 1, y: nil}
p(h.any? { |pa| p [pa] })
p(h.all? { |k, v| p v })
p(h.none? { |k, v| p k, v })
p(h.one? { |k, v| pp v })
p(h.count { |pa| p pa })
p(h.find { |k, v| p v })
p(h.partition { |k, v| p v })
p(h.min_by { |k, v| p k })
p(h.max_by { |k, v| p k })
p(h.group_by { |k, v| p v })

a = [1, nil, 3]
p(a.any? { |x| p x })
p(a.all? { |x| p x })
p(a.none? { |x| p [x] })
p(a.one? { |x| pp x })
p(a.count { |x| p x })
p(a.find { |x| p x })
p(a.partition { |x| p x })
p(a.compact.min_by { |x| p x })
p(a.compact.max_by { |x| p x })
p(a.compact.group_by { |x| p x.odd? })

def twice
  [yield(1), yield(2)]
end
p(twice { |i| p i * 10 })
