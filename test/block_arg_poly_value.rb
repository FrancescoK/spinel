# `m(&expr)` where expr is poly -- here `s` answers an Integer at one site
# and a Proc at another -- or a Method, and m takes its block as a real `&b`
# parameter. The sites that hand a block argument to such a parameter had an
# arm for a Proc-typed expression alone and wrote NULL for anything else:
# the method ran without its block, and the expression was never evaluated.
# `super(x, &poly)` was refused outright, a Method read out of a container
# raised TypeError into a yielding method, and a constructor cast a boxed
# value to a proc pointer unchecked.
def s(tag, v) = (puts tag; v)

def kw(x, a: 0, b: 0, &blk) = [x, a, b, blk ? blk.call : nil]
def pos(x, &blk) = [x, blk ? blk.call : nil]
def bare(&blk) = blk ? blk.call(3) : :none
def fwd(q) = pos(1, &q)
def each_one(x) = block_given? ? yield(x) : :none
def run(x, &blk) = blk ? blk.call(x) : :none

class Obj
  def m(x, &blk) = [x, blk ? blk.call : nil]
  def k(x, a: 0, &blk) = [x, a, blk ? blk.call : nil]
  def self.cm(x, &blk) = [x, blk ? blk.call : nil]
end

class Base
  def m(x, &blk) = [x, blk ? blk.call : nil]
end

class Poly < Base
  def m(x, &blk) = super(x, &[1, blk][1])
end

class ViaMethod < Base
  def m(x) = super(x, &method(:tag))
  def tag = :meth
end

class Keep
  def initialize(&blk) = @blk = blk
  def go(x) = @blk ? @blk.call(x) : :none
end

class Adder
  def initialize(n) = @n = n
  def add(v) = v + @n
end

pr = proc { :blk }

# the positional argument is evaluated before the block expression
p kw(s(:pos, 1), a: 2, &s(:blk, pr))
p pos(s(:pos, 1), &s(:blk, pr))
p kw(1, &s(:blk, pr))
p bare(&s(:blk, proc { |v| v * 2 }))

o = Obj.new
p o.m(1, &s(:blk, pr))
p o.k(1, a: 2, &s(:blk, pr))
p Obj.cm(1, &s(:blk, pr))

# a poly value read out of a container, and one that is nil at run time
q = [1, pr][1]
p pos(1, &q)
p Obj.cm(1, &q)
p method(:pos).call(1, &q)
p pos(1, &(ARGV.empty? ? pr : nil))
p pos(1, &(ARGV.empty? ? nil : pr))

# a parameter bound to a proc at one call and nil at the other
p fwd(pr)
p fwd(nil)

# super with a poly block, and with a Method
p Poly.new.m(1, &pr)
p Poly.new.m(1)
p ViaMethod.new.m(1)

# a Method held in a local, and one read out of a container
adder = Adder.new(10)
p adder.add(0)
mo = adder.method(:add)
p run(3, &mo)
p each_one(3, &mo)
p method(:run).call(3, &mo)
p Keep.new(&mo).go(3)
mq = [1, adder.method(:add)][1]
p run(4, &mq)
p each_one(4, &mq)
p Keep.new(&mq).go(4)
p Keep.new(&[1, proc { |v| v * 5 }][1]).go(4)
