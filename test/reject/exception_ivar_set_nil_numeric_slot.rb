# An exception class's Integer ivar keeps no nil of its own, so a reflective
# set of nil into it on a rescued exception stays refused.
class Counted < StandardError
  def initialize(m = "c"); super; @n = 1; end
end
x = Counted.new
begin
  raise x
rescue => e
  p e.instance_variable_set(:@n, nil)
end
