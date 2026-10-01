# Array#sum with a block keeps an Integer, a Float or (from a String seed) a
# String accumulator in its own C slot; every other block value folds boxed,
# and the call answers that boxed value: CRuby's TypeError from `0 + [x]`,
# an Array seed's concatenation, a Bignum or a Rational total, or the seed
# itself for an empty receiver.
def t(&b) = (b.call rescue $!.message)
p t { [1, 2].sum { |x| [x] } }
p t { [1, 2].sum { "s" } }
p t { [].sum { "s" } }
p t { [1, 2].sum(0.0) { |x| [x] } }
p t { [1, 2].sum { |x| x * 10**20 } }
p t { [1, 2].sum { |x| {a: x} } }
p t { [1, 2].sum { |x| 1..x } }
p t { [1, 2].sum([]) { |x| [x] } }
p t { [[1], [2]].sum([]) { |x| x } }
p t { [1, 2].sum { |x| x.to_r } }
p t { [1.5].sum { |x| [x] } }
p t { (1..2).sum { |x| [x] } }
p t { [1, 2].sum("") { |x| x.to_s } }
p t { [1, 2].sum { |x| x * 2 } }
p t { [1, 2].sum { |x| x * 0.5 } }
p t { [1, 2].sum(0.0) { |x| x } }
p t { [1, 2].sum { true } }
p t { [].sum { [1] } }
