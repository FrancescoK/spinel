# A method that yields from a block it passes to `map` on its own reader's
# value. While the procs pass looks at it, the reader answers an Array, so the
# block is spliced with `map` and the method with its caller. The reader's
# value turns poly only later, when the late widening settles what
# `preloaded` stores from a method whose value no call reaches (`target` has
# no type until then). A poly `map` takes its block as a proc, where the
# caller's block is out of reach: the `yield` was refused at compile time.
# The method takes its block as a proc once its receiver is poly, whichever
# pass widened it.
class Rel
  def initialize(src)
    @src = src
    @records = nil
  end

  def preloaded(records, loaded)
    @records = records if loaded
    self
  end

  def loaded_records
    records = @records
    if records.nil?
      records = @src.dup
      @records = records
    end
    records
  end

  def each
    loaded_records.each { |x| yield x }
  end

  def map
    loaded_records.map { |x| yield x }
  end
end

class Box
  def target
    cache
  end

  # never called: its value has no type until the late widening
  def cache
    if missing_value.nil?
    end
  end

  def each_part(&block)
    Rel.new([1]).preloaded(target, false).each(&block)
  end
end

def doubled(rel)
  rel.map { |w| w * 2 }
end

p doubled(Rel.new([1, 2, 3]))
p doubled(Rel.new([]))
out = []
Rel.new([4, 5]).each { |x| out << x }
p out
