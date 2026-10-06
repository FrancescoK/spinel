# An Integer slot that can hold nil, shifted: nil has no << or >>, so the
# shift raises NoMethodError. The nil sentinel was shifted as a number:
# `>> 1` answered -4611686018427387904 and `<< 1` raised RangeError.
class Box
  attr_accessor :v
  def initialize(v); @v = v; end
  def shl = @v << 1
  def shr(k) = @v >> k
end

k = ARGV.size + 2
p Box.new(3).v << 2
p Box.new(40).v >> k
p Box.new(5).shl
p Box.new(48).shr(k)

nb = Box.new(nil)
[-> { nb.v << 1 }, -> { nb.v >> 1 }, -> { nb.v << k }, -> { nb.v >> k },
 -> { nb.shl }, -> { nb.shr(k) }].each do |f|
  begin
    p f.call
  rescue NoMethodError => e
    p e.class
  end
end

# the op-assign through the writer, its value used
x = Box.new(nil)
begin
  y = (x.v <<= 1)
  p y
rescue NoMethodError => e
  p e.class
end
