# spinel: gc-stress
# `a[key] op= v` on a typed Array held in a local: a key that runs code
# (a call) left the receiver alone, so the local's own root still holds the
# array and the receiver's temp is not rooted again on every turn. A key or
# a right-hand side that rebinds the local, directly or through a closure
# over it, leaves the temp the old array's only holder, and keeps its root.

def bump(n) = n % 3
# a receiver only its local holds: a literal's own temp would hold it too
def ints3 = [1, 2, 3]
def floats3 = [1.0, 2.0, 3.0]

def hist(rows, h, n)
  i = 0
  while i < n
    h[(i % 2) * 4 + rows.getbyte(i)] += 0.5
    i += 1
  end
  h
end

p hist("\x01\x02\x03".b * 4, Array.new(8, 0.0), 12)

def ints(n)
  a = [0, 0, 0]
  n.times { |i| a[bump(i)] += "x#{i}".size }
  a
end
p ints(30)

# the key rebinds the receiver's local: the write lands in the old array,
# which nothing else holds while the key allocates
def rebind_key
  a = ints3
  a[(a = [10, 20, 30] + [Array.new(1000) { |i| "s#{i}" }.size]; 1)] += 5
  a
end
p rebind_key

# ...and the right-hand side
def rebind_rhs
  a = floats3
  a[bump(4)] += (a = Array.new(1000) { |i| i.to_f }; Array.new(1000) { |i| "s#{i}" }.size * 0.25)
  [a.size, a.sum]
end
p rebind_rhs

# a closure over the local rebinds it from inside the key
def rebind_proc
  a = ints3
  swap = -> { a = Array.new(1000) { |i| i * 2 }; Array.new(1000) { |i| "s#{i}" }.size % 3 }
  a[swap.call] += 7
  [a.size, a.sum]
end
p rebind_proc

class Hist
  def initialize
    @h = [0, 0, 0]
  end
  def swap
    @h = Array.new(1000) { |i| "x#{i}" }.map(&:size)
    0
  end
  def run
    @h[swap] += 1
    @h.sum
  end
end
p Hist.new.run
