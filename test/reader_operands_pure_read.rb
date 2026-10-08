# Operands that are all pure reads -- readers, typed-array reads, arithmetic --
# are evaluated in place: nothing between them can run code or allocate, so
# they need no ordering and no roots. `m.data[i * m.cols + j]` bound the
# reader's array to a rooted temp on every iteration; the root pinned it in
# memory and cost 1.7x on a loop that only reads.
#
# Everything that is NOT a pure read keeps its ordering, and each case below
# is one the pure test must turn down.
# spinel: gc-minor
class Matrix
  attr_reader :data, :cols
  def initialize(rows, cols)
    @cols = cols
    @data = Array.new(rows * cols) { |i| i * 0.5 }
  end
end

def total(m, rows)
  s = 0.0
  i = 0
  while i < rows
    j = 0
    while j < m.cols
      s += m.data[i * m.cols + j]
      j += 1
    end
    i += 1
  end
  s
end
p total(Matrix.new(30, 20), 30)

# an argument that runs a method which reassigns what the reader reads:
# the receiver is read first, and the old array stays alive for the call
class Holder
  attr_reader :data
  def initialize
    @data = [10, 20, 30, 40]
  end
  def swap(i)
    @data = [-1, -2, -3, -4]
    junk = []
    100.times { |k| junk << Array.new(32) { |q| q + k } }
    i
  end
end
t = 0
200.times do |n|
  h = Holder.new
  t += h.data[h.swap(n % 4)]
end
p t

# a `def` overriding the reader is a method, with whatever effects it has:
# here each call replaces the array, so the receiver's copy must be read first
# and kept alive while the argument's call allocates
class Base
  attr_reader :vals
  def initialize
    @vals = [0, 1, 2]
  end
end
class Loud < Base
  def vals
    @vals = @vals.map { |x| x * 10 }
    junk = []
    100.times { junk << [-7, -7, -7] }
    @vals
  end
end
r = []
50.times do
  l = Loud.new
  r << l.vals[l.vals[1] / 100]
end
p r.uniq
