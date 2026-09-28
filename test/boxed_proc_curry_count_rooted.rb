# curry(n) on a Proc read out of a mixed container, with a count that is a
# fresh object whose to_int allocates: the count is held by nothing but the
# call while to_int runs, so it has to stay rooted across that allocation.
# Filler has Count's shape, so a swept Count's slot is reused by one and a
# stale read answers the Filler's value.
class Count
  def initialize(v)
    @v = v
    @w = v + 1
  end

  def to_int
    junk = (1..300).map { |i| Filler.new(i * 7) }
    junk.size
    @v
  end
end

class Filler
  def initialize(v)
    @v = v
    @w = v + 1
  end
end

l3 = [->(a, b, c) { a + b + c }, 0][0]
bad = 0
100.times do
  c = l3.curry(Count.new(3))
  bad += 1 unless c[1][2][3] == 6
end
p bad

pr = [proc { |a, b| [a, b] }, 0][0]
p pr.curry(Count.new(2))[1][2]

begin
  l3.curry(Count.new(2))
rescue ArgumentError => e
  p e.message
end
