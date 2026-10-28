# An object that no Array conversion takes, or a Regexp, as the operand of
# concat, replace, +, -, |, &, union, difference, intersection or product
# raises CRuby's TypeError, naming the object's own class.
class P; end
class S < P; end
class R
  def to_ary = [5]
end
class Loud
  def to_ary
    puts "Loud#to_ary"
    [6]
  end
end

class AS < Array
  def initialize(*a)
    @x = 1
    super
  end
end

def pq(f) = f ? P.new : nil

def t
  yield
rescue TypeError, FrozenError => e
  p [e.class, e.message]
end

t { p([1] + P.new) }
t { p([1] - P.new) }
t { p([1] | /x/) }
t { p([1] & S.new) }
t { p([1].product(P.new)) }
t { p([1].union(P.new)) }
t { p([1].difference([1], P.new)) }
t { p([1].intersection(P.new)) }
t { p([1].replace(P.new)) }
t { p([1].concat(P.new)) }
t { p([1].concat(/x/)) }
t { p([1].concat([2], S.new)) }
t { p([1].concat(pq(false))) }
t { p([1] + pq(false)) }
t { p([1].freeze.concat(P.new)) }
t { p(["a"].concat(P.new)) }
t { p([1.5] + P.new) }
t { p([1, "a"].concat(P.new)) }
a = [1]
t { a.concat(P.new) }
t { a.concat(/x/) }
t { a.concat([3], S.new) }
p a
# an operand ahead of the misfit converts first, at its turn
t { [1].concat(Loud.new, P.new) }
t { [1].union(Loud.new, P.new) }
t { [1].concat(R.new, S.new) }
p a
# an Array subclass instance is an Array
p [1].concat(AS.new([4]))
p [1] + AS.new([4])
p [1].union(AS.new([4]))
p [1].concat(R.new)
p [1] + R.new
