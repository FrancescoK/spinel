# Kernel#Hash called on self answers the converted hash, as the bare call
# does: inference typed Integer, Float, String, Rational, Complex and Array
# on such a receiver but not Hash, which the emitter takes as Kernel's too,
# so the value read as nil.
class Conf
  def initialize(h)
    @h = h
  end

  def table
    self.Hash(@h)
  end

  def empty_table
    self.Hash(nil)
  end

  def count
    self.Hash(@h).size
  end
end

c = Conf.new({ a: 1, b: 2 })
p c.table
p c.table[:b]
p c.count
p c.empty_table
p c.empty_table.empty?
