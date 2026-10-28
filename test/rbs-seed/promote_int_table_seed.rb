# An `Array[Array[Integer]]` ivar seed under --int-overflow=promote: a row
# holding an arithmetic result is a row of boxed Integers, which the seed's
# Integer means in that mode too, so the table stays boxed rather than the
# seed being refused as contradicted by rows of another kind.
# The Makefile builds it with --int-overflow=promote; its rows pass 2^63, so
# share-strings-test (which compiles without it) leaves it out.
# spinel: rbs-seed-check
# spinel: rbs-seed-no-share
class PromoteTableSeed
  def initialize
    @rows = []
  end

  def add(a, b)
    @rows << [1, 2]
    @rows << [a, a * b]
    self
  end

  def rows
    @rows
  end
end

p PromoteTableSeed.new.add(1, 2).rows
p PromoteTableSeed.new.add(2**40, 2**40).rows
p 2**70 >> 60
