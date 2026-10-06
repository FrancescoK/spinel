# An instance variable another write already types keeps that slot when it
# is also destructured from a boxed value (optcarrot's PPU @io_addr), and an
# untyped or nil one takes the boxed elements
class Lut
  def initialize
    @addr = 0
    @fetched = nil
    @lut = (0..3).map { |i| [i * 16, [i, i + 1], i] }
  end

  def fetch(i)
    @addr, @fetched, = @lut[i]
    @addr & 0x1f
  end

  def fetched = @fetched
end
l = Lut.new
p l.fetch(1), l.fetched
p l.fetch(3), l.fetched
