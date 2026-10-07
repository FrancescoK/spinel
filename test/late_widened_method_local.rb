# A local assigned a method's value, and the parameter it is passed to,
# follow that method when an ivar it answers widens after inference: the
# ivar here is fed only by `restore(nil)`. Typed with the Integer the
# method had before, the local turned a nil into the Integer sentinel, and
# a callee taking it boxed read the sentinel as a number.

class Sprite
  def initialize = (@bits = 5; @ready = true; @scale = 1.5)

  def restore(v) = @bits = v
  def restore_scale(v) = @scale = v

  def current_row = (@bits if @ready)
  def row_with(k) = (@bits if k > 0)
  def scale = @scale

  def run
    bits = current_row
    [1].each { |x| p hit(x, bits) }
    other = self.row_with(1)
    p hit(1, other)
    s = scale
    p hit(1, s)
    p late(bits)
  end

  def late(a = 0, bits) = reloaded(bits)

  def hit(x, bits)
    return if x < 0

    reloaded(bits)
  end

  def reloaded(bits)
    return :none unless bits

    bits.is_a?(Integer) && bits.zero? ? :zero : bits
  end
end

s = Sprite.new
s.run
s.restore(nil)
s.restore_scale(nil)
s.run
p s.reloaded("row")
