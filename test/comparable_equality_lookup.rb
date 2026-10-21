# Comparable's equality shadows methods below its place in the ancestors.
class LookupParent
  def ==(other) = true
end
class LookupChild < LookupParent
  include Comparable
end
class LookupPrepended
  def ==(other) = true
  prepend Comparable
end
module LookupEquality
  def ==(other) = true
end
class LookupBefore
  include LookupEquality
  include Comparable
end
class LookupAfter
  include Comparable
  include LookupEquality
end
class LookupReopenedChild < LookupParent
end
class LookupReopenedChild
  include Comparable
end
class LookupReopenedPrepended
  def ==(other) = true
end
class LookupReopenedPrepended
  prepend Comparable
end
class LookupReopenedBefore
  include LookupEquality
end
class LookupReopenedBefore
  include Comparable
end
class LookupReopenedAfter
  include Comparable
end
class LookupReopenedAfter
  include LookupEquality
end
xs = [LookupChild.new, LookupChild.new,
      LookupPrepended.new, LookupPrepended.new,
      LookupBefore.new, LookupBefore.new,
      LookupAfter.new, LookupAfter.new,
      LookupReopenedChild.new, LookupReopenedChild.new,
      LookupReopenedPrepended.new, LookupReopenedPrepended.new,
      LookupReopenedBefore.new, LookupReopenedBefore.new,
      LookupReopenedAfter.new, LookupReopenedAfter.new, 1]
[[0, 1], [2, 3], [4, 5], [6, 7],
 [8, 9], [10, 11], [12, 13], [14, 15]].each do |i, j|
  begin
    p(xs[i] <= xs[j])
  rescue ArgumentError => e
    p e.class
  end
  begin
    p [xs[i], xs[j]].sort.size
  rescue ArgumentError => e
    p e.class
  end
end
