# A Hash local keyed by an Integer that can be nil, answered through a join
# that is stored into a box: a local that is also written something else
# (`keep = (seen) || {}`), or an ivar (`@last = (seen) || {}`). A read that
# ends the arm of a join, or is its operand, was taken to hand the Hash on whole
# into a slot the late widening cannot retype, so the Hash stayed typed and the
# nil key was refused at run time (a TypeError) where CRuby stores it. A box
# takes the widened Hash as the read now types it.
def build_local(a)
  seen = {}
  a.each_with_index { |x, i| seen[x] = i }
  keep = (seen) || {}
  keep
end

class Ix
  def build(a)
    seen = {}
    a.each_with_index { |x, i| seen[x] = i }
    @last = (seen) || {}
  end

  def last = @last
end

v = [1, 2][ARGV.size + 5]
p build_local([1, v, 1])
i = Ix.new
p i.build([1, v, 1])
p i.last[nil], i.last[1]
p i.last.size
