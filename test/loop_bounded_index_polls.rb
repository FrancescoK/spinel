# A program with threads and finalizers polls inside its loops: another thread
# may run at the safepoint, a finalizer at the finalizer poll, and either can
# shrink an array. A loop that reads a[i] without a bounds test (`i = 0; while
# i < a.length ... a[i] ... i += 1`) therefore polls ahead of its `i < a.length`
# test, not between that test and the read -- so a read always follows a test
# of the array's current length. (The threads and the finalizer are what make
# the program poll; the loop itself runs on one thread.) A loop that keeps its
# bounds test still caches the array's header, and polls in its body; it reads
# the header again after either poll.
# spinel: gc-minor
class Holder
  def initialize(n); @n = n; end
end
ObjectSpace.define_finalizer(Holder.new(1), proc { })

def total(a)
  s = 0
  i = 0
  while i < a.length
    s += a[i]
    i += 1
  end
  s
end

def back(a)
  s = 0
  j = 0
  while j < 1000
    s += a[999 - j]
    j += 1
  end
  s
end

arr = Array.new(1000) { |k| k }
p Thread.new { total(arr) }.value
p total(arr)
p Thread.new { back(arr) }.value
p back(arr)
