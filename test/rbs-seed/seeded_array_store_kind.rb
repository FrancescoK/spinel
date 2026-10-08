# A true `Array[Integer]` seed pins @storage and @lazy, so an array of another
# kind stored into them converts: here a helper only ever handed the empty
# `[]` default (through a subclass's bare super) is typed a general Array, and
# its raw pointer went into the IntArray slot, so the C did not build. The
# plain, value-position and `||=` stores all take the conversion.
# spinel: rbs-seed-run
class SeedStoreMem
  def initialize(initial = [])
    @storage = fill(initial)
  end

  def reset = (@storage = fill([]))
  def lazy = (@lazy ||= fill([]))

  def [](i) = @storage[i]
  def size = @storage.size

  private

  def fill(initial)
    array = initial.dup
    0.upto(3) { |i| array[i] ||= 0 }
    array
  end
end

class SeedStoreRecording < SeedStoreMem
  def initialize
    super
    @log = []
  end
end

r = SeedStoreRecording.new
p r[2]
p r.size
p r.reset
p r.lazy.sum
