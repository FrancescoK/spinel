# CRuby's containers and Object#=== compare with rb_equal, which answers
# true for the same object before calling its ==. The == operator itself
# still calls the method. K#== logs each call and answers false.

class K
  def initialize(log) = @log = log
  def ==(o)
    @log << :eq
    false
  end
end

# a == that answers nil (a boxed answer) rather than false
class N
  def initialize(log) = @log = log
  def ==(o)
    @log << :neq
    o.is_a?(Integer) ? true : nil
  end
end

log = []
k = K.new(log)
j = K.new(log)
x = [k, 1][ARGV.size]

def show(log, v)
  p [v, log.size]
  log.clear
end

show(log, [k].include?(k))
show(log, [j, k].index(k))
show(log, [k, j].rindex(k))
show(log, [k, j, k].count(k))
show(log, [k] == [k])
show(log, [k, j].assoc(k).nil?)
show(log, [[1, k]].rassoc(k).nil?)
show(log, [k].include?(x))
show(log, [x].include?(k))
show(log, [k].any?(k))
show(log, {a: k}.value?(k))
show(log, {a: k}.key(k))
show(log, {a: k} == {a: k})
a = [k, j]
a.delete(k)
show(log, a.size)

show(log, k === k)
show(log, k === x)
show(log, k === j)
r = case k
    when k then :hit
    else :miss
    end
show(log, r)
r = case x
    when k then :hit
    else :miss
    end
show(log, r)
r = case j
    when k then :hit
    else :miss
    end
show(log, r)

# the operator calls the method, also on the same object
show(log, k == k)
show(log, x == x)
show(log, k != k)

nlog = []
n = N.new(nlog)
show(nlog, [n].include?(n))
show(nlog, n === n)
r = case n
    when n then :hit
    else :miss
    end
show(nlog, r)
show(nlog, n == n)
