# sum(seed) accumulates in the SEED's class, with Ruby's `+` at every step:
# a Rational or Bignum seed keeps its own arithmetic, a Float one widens the
# whole sum, and nil / a String / an Array reach the raise that operator
# produces -- worded for the element's class, not for Integer.
def t
  p yield
rescue => e
  p [e.class, e.message]
end

# an integer array, one seed class per line
t { [1, 2, 3].sum(Rational(1, 2)) }
t { [1, 2, 3].sum(10**30) }
t { [1, 2, 3].sum("x") }
t { [1, 2, 3].sum(nil) }
t { [1, 2, 3].sum(false) }
t { [1, 2, 3].sum(1.0i) }
t { [1, 2, 3].sum([]) }
t { [1, 2, 3].sum(0.5) }              # a Float seed already widened: 6.5
t { [3, 4].sum(10**30) - 10**30 }

# a float array
t { [1.0, 2.0].sum(Rational(1, 2)) }
t { [1.0, 2.0].sum(10**30) }
t { [1.0, 2.0].sum("x") }
t { [1.0, 2.0].sum(nil) }
# the exact phase gives way to compensated summation at the first Float
t { ([0.1] * 10).sum(0r) }

# an integer Range adds the closed form to an Integer seed and runs every
# other class through Kernel#Float
t { (1..3).sum(Rational(1, 2)) }
t { (1..3).sum(1.5r) }
t { (1..3).sum(10**30) }
t { (1..3).sum("x") }
t { (1..3).sum(nil) }
t { (1..3).sum(false) }
t { (1..3).sum([]) }
t { (1...1).sum(Rational(1, 2)) }     # empty: the seed, unconverted
t { (1..3).sum(0.5) }                 # a Float seed already answered 6.5
t { ("a".."c").sum(0.5) }
t { ("a".."c").sum(0) }               # unchanged wording, from the generic `+`

# a Hash folds its [key, value] pairs into the seed
t { { a: 1, b: 2 }.sum(nil) }
t { { a: 1, b: 2 }.sum(false) }
t { {}.sum(nil) }
t { { a: 1, b: 2 }.sum(0) }           # already the Integer coercion failure
t { { a: 1, b: 2 }.sum([]) }          # already the concatenation

# a seed of the numeric tower beside an element that is no number at all: the
# arithmetic reaches no tower arm, so the operator itself reports the failure
t { ["x"].sum(Rational(1, 2)) }
t { ["x"].sum(10**30) }               # pin: already the Integer coercion failure
t { { 1 => 2 }.sum(10**30) }          # pin: likewise, over the [k, v] pairs
t { ["a"].reduce(Rational(1, 2), :+) }
t { [10**30, "x"].inject(:+) }

# the compensated phase carries CRuby's NaN and Infinity arms
t { [Float::INFINITY, 1.0].sum }
t { [1.0, 2.0].sum(Float::INFINITY) }
t { [1.0, Float::NAN].sum }                   # pin
t { [Float::INFINITY, -Float::INFINITY].sum } # pin
t { [Float::INFINITY, 1].sum(0.5) }           # pin
t { a = [[Float::INFINITY, 1.0], 0][0]; a.sum(0) }   # pin, through the boxed fold
# a run BROKEN by a non-number keeps the uncompensated total, as CRuby's
# not_float label does; only an exhausted run folds the compensation back
t { a = [[0.1, 0.2, 0.3, Complex(0, 1)], 0][0]; a.sum(0.0) }   # pin

# receivers read out of a container, so their class is only known at run time
t { r = [(1..3), 0][0]; r.sum(10) }
t { a = [[1, 2], 0][0]; a.sum(Rational(1, 2)) }     # pin: already (7/2)
t { a = [[1, 2.5], 0][0]; a.sum(Rational(1, 2)) }   # pin: the exact phase gives way mid-fold

# a user class as the seed: the fold applies ITS `+`, which the seeded sum
# names nowhere, so the operator has to be kept reachable for it
class Money
  def initialize(cents); @cents = cents; end
  def +(other); Money.new(@cents + other); end
  def inspect; "$#{@cents}"; end
end
class Tally
  attr_reader :n
  def initialize(n); @n = n; end
  def coerce(other); [Tally.new(other), self]; end
  def +(other); Tally.new(@n + (other.is_a?(Tally) ? other.n : other)); end
  def inspect; "T(#{@n})"; end
end
t { [1, 2, 3].sum(Money.new(0)) }
t { [1, 2, 3].sum(Tally.new(0)) }

# the seed expression, and the receiver expression, run exactly once
$n = 0
def seed
  $n += 1
  Rational(1, 2)
end
p [1, 2].sum(seed)
p $n
$m = 0
def nums
  $m += 1
  [1, 2]
end
p nums.sum(Rational(1, 2))
p $m

# A FLOAT seed compensates from the first element: Ruby 4.0.7 answers 0.6 for
# `.sum(0.0)` as for `.sum` and `.sum(0)` (4.0.4 ran plain `+` from a Float
# seed). Both the typed float sum and the boxed fold have to draw that line in
# the same place.
p [0.1, 0.2, 0.3].sum
p [0.1, 0.2, 0.3].sum(0)
p [0.1, 0.2, 0.3].sum(0.0)
p [0.1, 0.2, 0.3].sum(1)
p [0.1, 0.2, 0.3].sum(1.0)
p [1, 0.1, 0.2, 0.3].sum(0.0)
p [0.1, 0.2, 0.3].sum(Rational(0, 1))
p [[0.1, 0.2, 0.3], 0][0].sum(0.0)
p [[0.1, 0.2, 0.3], 0][0].sum(0)
p [[0.1, 0.2, 0.3], 0][0].sum
p [Float::INFINITY, 1.0].sum(0.0)
