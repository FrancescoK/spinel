# A boxed Enumerator's each through the run-time dispatch answers its walk's answer
# Where a class of the program has an each of its own, a boxed receiver's
# each with a block passed as a Proc goes through the dispatch, whose walk
# of an Enumerator answered the Enumerator: a generator's `each` answers its
# body's value, a materialized one's its source. The literal-block form is
# here too.

class Bag
  def initialize(*xs) = @xs = xs
  def each
    @xs.each { |x| yield x }
    self
  end
end
def box(x) = [x, Bag.new].first
pr = proc { |x| x }
runs = 0
gen = Enumerator.new { |y| runs += 1; y << 1; y << 2; :body_done }
p box(gen).each(&pr), runs
p box([1, 2, 3].each).each(&pr)
p box((1..3).each).each(&pr)
p box([9]).each(&pr)
runs = 0
p box(gen).each { |x| x }, runs
p box(Bag.new(5)).each(&pr).class
