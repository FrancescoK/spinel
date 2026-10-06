# Comparable#== answers true for the receiver itself without calling <=>,
# as CRuby's cmp_equal does: a <=> with a side effect must not run for
# `x == x`. Covers a typed receiver and argument (in place and through a
# temp), `!=`, a boxed receiver, Array#include?, case/when and a parameter
# that holds the receiver. Two different objects still call <=>. A
# receiver its argument reassigns (`@a == (@a = @b)`) is compared as it was
# before the argument ran, as CRuby evaluates the receiver first.

class M
  include Comparable
  attr_reader :log
  def initialize(log) = (@log = log)
  def <=>(o) = (@log << "z"; 0)
end

log = +""
m = M.new(log)
other = M.new(log)
ms = [m]

r = m == m
p [r, log]
r = m != m
p [r, log]
r = m == ms[0]
p [r, log]
r = ms[0] == m
p [r, log]
r = m == other
p [r, log]

x = [m, 1][0]
r = x == x
p [r, log]
r = [m].include?(m)
p [r, log]
r = (case m when m then :same else :other end)
p [r, log]

def same(a, b) = a == b
r = same(m, m)
p [r, log]
r = same(m, other)
p [r, log]

# a <=> that can answer nil
class N
  include Comparable
  attr_reader :calls
  def initialize = (@calls = 0)
  def <=>(o) = (@calls += 1; nil)
end
n = N.new
r = n == n
p [r, n.calls]

# a receiver its argument reassigns
class R
  include Comparable
  attr_reader :n
  def initialize(n, log) = (@n = n; @log = log)
  def <=>(o) = (@log << "#{n}#{o.n} "; n - o.n)
end

class H
  def initialize(log)
    @log = log
    @a = R.new(3, log)
    @b = R.new(3, log)
  end

  def swap = (@a = @b)

  def go
    r1 = @a == (@a = @b)
    @a = R.new(4, @log)
    r2 = @a != (@a = R.new(9, @log))
    @a = R.new(5, @log)
    r3 = @a == swap
    [r1, r2, r3]
  end
end

rl = +""
p [H.new(rl).go, rl]
k = R.new(1, rl)
r = k == (k = R.new(1, rl))
p [r, rl]
