# spinel: int64
# spinel: share
# spinel: gc-minor
# A seeded sum starts with the seed, including when it is boxed. Empty
# arrays keep its class; non-empty arrays add in order, with compensation
# when Float elements appear. Mutating a result here reads that same name.
def sum_seed(n)
  case n
  when 0 then +"ab"
  when 1 then [9]
  when 2 then 10
  when 3 then 0.0
  else Rational(1, 2)
  end
end

def empty_items
  [1, "unused"].take(0)
end

def attempt
  p yield
rescue TypeError => e
  p [e.class, e.message]
end

p empty_items.sum(sum_seed(0))
p empty_items.sum(sum_seed(1))
p empty_items.sum(sum_seed(2))
p empty_items.sum(sum_seed(3))
p empty_items.sum(sum_seed(4))
text = empty_items.sum(sum_seed(0))
text << "!"
p text

p ["c", :unused].take(1).sum(sum_seed(0))
p [[1, 2], :unused].take(1).sum(sum_seed(1))
p [1, 2.5].sum(sum_seed(2))
p [0.1, 0.2, 0.3, 0r].sum(sum_seed(3))
p [1, Rational(1, 4)].sum(sum_seed(4))
p [1, 0.25].sum(sum_seed(4))
p [-1.0e16, 1.0, 0r].sum(10000000000000000)
p [-1.0e16, 1.0, 0r].sum(10000000000000000r)
p ["c", :unused].take(1).sum("ab")
p [[1], [2]].sum([9])
p [[1], [2]].sum([])
p empty_items.sum("ab")
p empty_items.sum([9])
p empty_items.sum([])
attempt { ["c", 1].sum("ab") }
attempt { [[1], 2].sum([9]) }
attempt { ["c", 1].sum(sum_seed(0)) }
attempt { [[1], 2].sum(sum_seed(1)) }

p [1, 2].sum(sum_seed(4)) { |x| x }
p [1, 2].take(0).sum(sum_seed(0)) { |x| x }
p ["c", "d"].sum(sum_seed(0)) { |x| x }
p [1, 2].sum(sum_seed(1)) { |x| [x] }
p [1, 2.5].sum(sum_seed(2)) { |x| x }
p [0.1, 0.2, 0.3].sum(sum_seed(3)) { |x| x }
p [1, 2].sum(sum_seed(4))
p [1.0, 2.0].sum(sum_seed(4))
attempt { [1, 2].sum(sum_seed(0)) }
p [1, 2].sum(0.5)
p [0.1, 0.2, 0.3].sum(0.0)
p [Float::INFINITY, 1.0].sum(0.0) { |x| x }
p [Float::NAN, 1.0].sum(0.0) { |x| x }.nan?
p (1..3).sum(sum_seed(4))
p (1...1).sum(sum_seed(0))
p({ a: 1, b: 2 }.sum(sum_seed(4)) { |k, v| v })
p ["c", "d"].each.sum(sum_seed(0)) { |x| x }

$order = []
def sum_items
  $order << "receiver"
  [1, 2.5]
end
def ordered_seed
  $order << "seed"
  10
end
p sum_items.sum(ordered_seed)
p $order
