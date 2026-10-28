# spinel: int64
# spinel: needs-rbs-parser
# An `Array[Array[Integer]]` ivar under --int-overflow=promote: a row holding
# an arithmetic result is a row of boxed Integers, which the declaration
# means too, so the table stays boxed rather than the annotation being
# refused as a contradiction.
class Frag
  # @rbs @rows: Array[Array[Integer]]

  def initialize
    @rows = []
  end

  #: (Integer, Integer) -> Frag
  def add(a, b)
    @rows << [1, 2]
    @rows << [a, a * b]
    self
  end

  def rows
    @rows
  end
end

p Frag.new.add(1, 2).rows
p Frag.new.add(2**40, 2**40).rows
p 2**70 >> 60
