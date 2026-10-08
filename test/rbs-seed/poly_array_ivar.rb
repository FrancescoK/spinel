# The seed vocabulary accepts poly_array (the extractor emits it for
# Array[T] where T falls outside the int/float/string/symbol/nominal element
# subset, e.g. Array[untyped]); such an ivar seed used to be silently
# dropped, leaving the never-assigned slot to the poly backstop.
# spinel: rbs-seed-check
class SeedBox
  def kids
    @kids
  end
end

box = SeedBox.new
p box.kids.nil?
