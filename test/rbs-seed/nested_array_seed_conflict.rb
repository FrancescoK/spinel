# A nested seed against rows of the other kind is the same contradiction a
# flat seed reports: refused, not narrowed to whichever kind the code gave
# (#4484). The Makefile checks the refusal, so this never runs.
# spinel: rbs-seed-check
class SeedConflictTable
  def initialize(n)
    @a = Array.new(n) { Array.new(0, 0) }
  end
  def go
    @a[0] << 1
    p @a[0][0]
  end
end
SeedConflictTable.new(2).go
