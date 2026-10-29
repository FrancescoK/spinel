# A loop rescues StopIteration only where its body can raise one
# `loop { }` opens a setjmp frame to rescue StopIteration, which keeps every
# local its body writes in memory. A body nothing in which can raise
# StopIteration (here the first group) runs as a plain C loop; one that can,
# through an external iteration, a raise, a closed Queue or a method of the
# program, still ends at the StopIteration.

def count_to(n)
  i = 0
  loop do
    i += 1
    break if i >= n
  end
  i
end

def first_square_over(n)
  k = 0
  loop do
    k += 1
    return k * k if k * k > n
  end
end

def half(x) = x / 2

def halvings(n)
  steps = 0
  loop do
    break if n <= 1
    n = half(n)
    steps += 1
  end
  steps
end

p count_to(5), first_square_over(50), halvings(1000)
p(loop do
  break :done
end)
nested = 0
loop do
  j = 0
  loop do
    j += 1
    next if j.odd?
    nested += j
    break if j > 6
  end
  break
end
p nested

# an external iteration ends the loop, which answers the iteration's result
e = [1, 2, 3].each
got = []
r = loop { got << e.next }
p got, r

# a method of the program that iterates externally
class Feed
  def initialize(xs) = @e = xs.each
  def take = @e.next
end
f = Feed.new([4, 5])
seen = []
loop { seen << f.take }
p seen

# a yield in the body runs the caller's block, here one that iterates
def each_until_stop
  loop { yield }
  :stopped
end
e2 = [6, 7].each
out = []
p each_until_stop { out << e2.next }, out

# a raise of StopIteration, or of a subclass, ends it too
class Done < StopIteration; end
k = 0
loop do
  k += 1
  raise Done if k == 3
end
p k
loop { raise StopIteration }
p :raised

# a push to a closed Queue raises ClosedQueueError, a StopIteration
q = Queue.new
q << 1
q.close
pushes = 0
loop do
  pushes += 1
  q << pushes
end
p pushes, q.size

# any other exception passes through
begin
  loop { raise ArgumentError, "bad" }
rescue ArgumentError => ex
  p ex.message
end
