# The receiver ivar is read before an index argument on a boxed value. Such
# an index is a plain lookup unless it can run Ruby code: here a user class
# defines `[]`, which reassigns the ivar, so the receiver must be read first
# (the old array), as CRuby does.
class Idx
  def initialize(owner) = @owner = owner
  def [](k)
    @owner.swap!
    1
  end
end

class Holder
  def initialize
    @data = [10, 20, 30]
    @lut = [Idx.new(self), 0][0]
  end

  def swap! = @data = [0, 0, 0]
  def read = @data[@lut[:x]]
  def data = @data
end

h = Holder.new
p h.read
p h.data
