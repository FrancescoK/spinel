# A block whose value is a call, without a block, to a method that yields
# (one that checks block_given?, forwards `&` or `...`, reaches a yielding
# parent through super, or a builtin written that way, like Enumerable's
# minmax): the splice answers the call's value.
def t = yield
def tp = p(yield)

class F1
  def m(a) = [a]
  def n(a) = a + 1
  def s(a) = "s#{a}"
end

class F2 < F1
  def m(...) = super
  def n(...) = super
  def s(...) = super
end

class Y1
  def m(a) = yield(a)
  def n(a) = yield(a)
  def s(a) = yield(a)
end

class G
  def g = block_given? ? yield : 5
  def h(&b) = b ? b.call : [7]
  def k(&) = w(&)
  def w = block_given? ? yield : [8]
end

p(Y1.new.m(1) { |x| [x] }, Y1.new.n(1) { |x| x }, Y1.new.s(1) { |x| x })
tp { F2.new.m(1) }
p t { F2.new.m(1) }
p t { F2.new.n(1) }
p t { F2.new.s(1) }
p t { G.new.g }
p t { G.new.h }
p t { G.new.k }
p t { G.new.g { 6 } }
p [1, 2].map { F2.new.m(_1) }
p t { t { F2.new.m(3) } }
v = t { G.new.g }
p v + 1
y = ARGV.size > 5 ? [9] : nil
p t { (y || [1, 3]).minmax }
p t { (y || [5, 1]).minmax.first }
