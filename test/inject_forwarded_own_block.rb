# a method's own block handed on to inject / reduce: where its caller gave
# none, the fold takes its blockless form

def seeded(a, s, &blk) = a.inject(s, &blk)
def bare(a, &blk) = a.reduce(&blk)
def two(a, i, s, &blk) = a.inject(i, s, &blk)
def words(a, s, &blk) = a.inject(s, &blk)

p seeded([1, 2, 3], :+)
p seeded([1, 2, 3], 10) { |x, y| x + y }
p words(%w[a b], :+)
p words(%w[a b], "z") { |x, y| x + y }

p bare([1, 2, 3]) { |x, y| x * y }
begin
  bare([1, 2, 3])
rescue ArgumentError => e
  p e.message
end

# a seed and an operator: the operator folds, and the block goes unused
p two([1, 2, 3], 1, :*)
p two([1, 2, 3], 1, :*) { |x, y| 0 }

# a block that is known only at run time
def by(a, s, &blk) = a.inject(s, &blk)
[[:+, nil], [2, proc { |x, y| x - y }]].each do |s, q|
  p by([1, 2, 3], s, &q)
end

# a written block beside a seed and an operator known only at run time
def op(a, s) = a.inject(1, s) { |x, y| 0 }
p op([1, 2, 3], :*)
def rop(r, s) = r.inject(1, s) { |x, y| 0 }
p rop(1..4, :*)
