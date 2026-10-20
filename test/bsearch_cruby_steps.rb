# Array#bsearch, Array#bsearch_index and Range#bsearch call their block on
# the elements CRuby's do, in the same order: the Array searches [lo, hi)
# from the middle, a Float Range bisects the bit patterns of its doubles as
# range.c's BSEARCH does, and an answer of another kind is CRuby's
# TypeError. The Arrays halved an inclusive [lo, hi], a finite Float Range
# took a hundred halvings of the reals, and a mixed answer found its
# element elsewhere.

def seen
  $m = []
  r = yield
  [r, $m]
end
def bits(xs) = xs.first(4).map { |x| [x].pack("G").unpack1("H*") }

a = [1, 3, 5, 7, 9, 11]
p seen { a.bsearch { |w| $m << w; w >= 8 } }
p seen { a.bsearch { |w| $m << w; w >= 20 } }
p seen { [1, 2, 3, 4].bsearch { |w| $m << w; 2 <=> w } }
p seen { [1, 2, 3, 4, 5, 6, 7].bsearch { |w| $m << w; [true, 1, -1][w % 3] } }
p seen { [0.5, 1.5, 2.5].bsearch { |w| $m << w; 1.5 - w } }
p seen { ["a", "c", "e", "g"].bsearch { |w| $m << w; w >= "d" } }
p seen { [1, 2, 3, 4, 5].bsearch_index { |x| $m << x; x >= 4 } }
p seen { [1, 2, 3, 4, 5].bsearch_index { |x| $m << x; 2 <=> x } }
p seen { [1, 2, 3, 4, 5, 6, 7].bsearch_index { |w| $m << w; [true, 1, -1][w % 3] } }
p seen { a.bsearch.each { |w| $m << w; w >= 8 } }
def pick(xs, i) = xs[i]
p seen { pick([a, "x"], 0).bsearch { |w| $m << w; w >= 8 } }

p seen { (1..10).bsearch { |x| $m << x; x >= 4 } }
p seen { (0..100).bsearch { |x| $m << x; 42 <=> x } }

def fl(res_xs) = [res_xs[0], res_xs[1].size, bits(res_xs[1])]
p fl(seen { (0.0..1.0).bsearch { |x| $m << x; x >= 0.5 } })
p fl(seen { (0.0...1.0).bsearch { |x| $m << x; x >= 2.0 } })
p fl(seen { (1..2.5).bsearch { |x| $m << x; x >= 2 } })
p fl(seen { (0.0..10.0).bsearch { |x| $m << x; 3.0 <=> x } })
p fl(seen { (1.0..).bsearch { |x| $m << x; x >= 100 } })
p fl(seen { (..0.0).bsearch { |x| $m << x; x >= -1 } })
fr = (0.25..4.0)
p fl(seen { fr.bsearch { |x| $m << x; x * x >= 2 } })

[-> { [1, 2].bsearch { |w| "x" } }, -> { [1, 2].bsearch { |w| [w, :s][1] } },
 -> { [1, 2].bsearch_index { |w| [w, :s][1] } }, -> { (1..3).bsearch { |x| "s" } },
 -> { (0.0..1.0).bsearch { |x| :s } }].each do |f|
  f.call
rescue TypeError => e
  puts e.message
end

# a NaN answer raises ArgumentError (NaN <=> 0 is nil), and a Rational or
# a Bignum answer is a number, by its sign, on every path
def nan_case(d)
  p [d, yield]
rescue ArgumentError => e
  p [d, e.message]
end
nan_case(:ary) { [1, 2, 3].bsearch { |x| Float::NAN } }
nan_case(:idx) { [1, 2, 3].bsearch_index { |x| Float::NAN } }
nan_case(:range) { (1..3).bsearch { |x| Float::NAN } }
nan_case(:frange) { (1.0..3.0).bsearch { |x| Float::NAN } }
p [1, 2, 3, 4].bsearch { |x| Rational(3 - x, 2) }
p [1, 2, 3, 4].bsearch_index { |x| (3 - x) * 2**70 }
p (1..10).bsearch { |x| Rational(7 - x, 3) }
p (1..10).bsearch { |x| (6 - x) * 2**70 }
