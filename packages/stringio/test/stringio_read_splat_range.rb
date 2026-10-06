# spinel: int64
# read(*args) on a boxed StringIO: a Float length past int64, NaN or an
# infinity is CRuby's RangeError, and one in range truncates
require "stringio"
class W
  def initialize(io) = @io = io
  def read(*a) = @io.read(*a)
end
def mk(i) = [StringIO.new(+"hello"), 1][i]
w = W.new(mk(0))
[1e100, -1e100, Float::NAN, Float::INFINITY, -Float::INFINITY].each do |f|
  begin
    w.read(f)
  rescue RangeError => e
    p e.message
  end
end
p w.read(2.9), w.read(1e1), w.read(1), w.read(1.0)
