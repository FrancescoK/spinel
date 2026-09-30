# The receiver ivar is read before an index argument on a boxed value. Such
# an index is a plain lookup unless it can run Ruby code: here a Hash's
# default block reassigns the ivar, so the receiver must be read first
# (the old array), as CRuby does.
class Holder
  def initialize
    @data = [10, 20, 30]
    @lut = [Hash.new { |h, k| @data = [0, 0, 0]; 1 }, 0][0]
  end

  def read = @data[@lut[:x]]
  def data = @data
end

h = Holder.new
p h.read
p h.data
