# A seed the program statically contradicts is a compile error, not a
# reinterpretation. Here the signature says Integer and the assignment is a
# String whose type inference already knows: a flat scalar slot fed a heap
# pointer, with no conversion in either direction.
#
# Not a snapshot test -- failing to compile is the passing outcome, so the
# Makefile runs it and asserts the diagnostic.
# spinel: rbs-seed-check
class Bad
  def initialize
    @v = nil
  end

  def set(x)
    @v = x
  end

  def get
    @v
  end
end

b = Bad.new
b.set("hello")
p b.get
