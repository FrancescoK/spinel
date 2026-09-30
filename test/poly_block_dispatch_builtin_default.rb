# A block call in statement position on a slot of no single type, where a
# user class defines the name with a block: a builtin Array reaching the
# dispatch still runs its own iterator.

class Grid
  def each_slice(n)
    yield [:grid, n]
    self
  end

  def each_cons(n)
    yield n
  end
end

class Sheet
  def each_slice(n, &blk)
    blk.call([:sheet, n])
  end
end

class Holder
  def initialize(v) = @v = v

  def run
    total = 0
    @v.each_slice(2) { |a| total += a.size; p a }
    @v.each_cons(3) { |a| p a }
    total
  end
end

p Holder.new([1, 22, 333, 4444]).run
p Holder.new(Grid.new).run

def slices(v)
  n = 0
  v.each_slice(3) { |a| n += 1; next if a.size > 5; p a }
  n
end
p slices([1, 2, 3, 4])
p slices(Sheet.new)
