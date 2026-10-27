# The rows of a `[[], []]` literal that take a value of another kind than an
# `Array[Array[Integer]]` seed's contradict it, as the rows of
# `Array.new(n) { [] }` do: refused, not kept boxed under the seed. The
# Makefile checks the refusal, so this never runs.
# spinel: rbs-seed-check
class LiteralRowConflict
  def initialize
    @b = [[], []]
    @b[1] << 5
  end
  def fill
    @b[0] << "x"
  end
  def report
    p @b[0]
    p @b[1]
  end
end
t = LiteralRowConflict.new
t.fill
t.report
