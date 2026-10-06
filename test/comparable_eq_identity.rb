# Comparable#== answers true for the receiver itself without calling <=>,
# as CRuby's cmp_equal does: a <=> with a side effect must not run for
# `x == x`. Covers a typed receiver and argument (in place and through a
# temp), `!=`, a boxed receiver, Array#include?, case/when and a parameter
# that holds the receiver. Two different objects still call <=>.

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
