# spinel: rbs-seed-check
# A rest or keyword rest parameter is typed by construction: its callers'
# arguments are gathered into a poly Array or Hash. A signature that
# declares an optional positional where the def gathers (`?Integer c` for
# `def m(*c)`, as a Rails application's `Relation#exists?(*conditions)` is
# declared `(?(Integer | String | nil) condition)`) put its field on the
# gathering slot, which took the scalar or box type of the element; the
# callers still passed the gathered Array, and cc refused the call. The
# field is not applied to a gathering slot, in either build, and the
# parameters beside it keep theirs.
class Rel
  def initialize
    @limit = 3
  end

  def exists?(*conditions)
    return false if conditions.length > 1
    return @limit > 0 if conditions.empty?
    conditions[0].nil? ? false : true
  end

  def any?
    exists?
  end

  def count_of(*ids)
    ids.length
  end

  def pick(first, *rest)
    "#{first}/#{rest.length}"
  end

  def opts(key, **named)
    "#{key}:#{named.length}"
  end

  def last_of(*xs, tail)
    "#{xs.length}+#{tail}"
  end
end

r = Rel.new
p r.any?
p r.exists?
p r.exists?(4)
p r.exists?(nil)
p r.exists?("a")
p r.exists?(1, 2)
args = [7]
p r.exists?(*args)
p r.count_of
p r.count_of(1, 2, 3)
p r.pick("a")
p r.pick("a", 1, 2)
p r.opts("k")
p r.opts("k", x: 1, y: 2)
p r.last_of(5)
p r.last_of(1, 2, 5)
