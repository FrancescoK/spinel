# A call that gives a block to a method two defs make, both yielding, runs
# the version defined when it runs, and the block gets that version's
# values: in a method body, through a class's method, and with a block
# passed by & as well as a literal one.
def each_two = (yield 1; yield 2)
def sum_two
  t = 0
  each_two { |x| t += x }
  t
end
p sum_two
def each_two = (yield 10; yield 20)
p sum_two

class Walk
  def step(n) = yield(n + 1)
  def go(n) = step(n) { |v| v * 2 }
  p new.go(1)
  def step(n) = yield(n + 100)
end
p Walk.new.go(1)

def pair = yield(1, 2)
def both = pair { |a, b| a + b }
p both
def pair = yield(3, 4)
p both
show = proc { |a, b| [a, b] }
def via_proc(pr) = pair(&pr)
p via_proc(show)
