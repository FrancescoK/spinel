# A method seeded `-> Array[Integer]` whose body builds a POLY array.
#
# The poly array is supposed to materialise into the typed one at the boundary
# (#1827). It did, as long as the element type the body inferred was `Integer`.
# When the element inferred `Integer?` -- one arm of the `id` dispatch can
# answer nil -- the block's value boxed as an int-or-nil, the body built an
# sp_PolyArray, and the return CAST the pointer to sp_IntArray * instead of
# materialising. The caller then read a PolyArray's header as an IntArray's and
# printed memory: `[0, 3, 0, 0, ...]` where CRuby prints `[1, 3]`. No
# diagnostic anywhere -- nothing in the Ruby, the RBS or the compiler output
# points at `Integer?` (#4424).
#
# The rule already existed one type family over. A boxed hash entering a slot
# of a concrete variant goes through a converting entry, because the variants
# are separate C structs and a pointer cast reinterprets one as another --
# silently (#3998). The array kinds are separate C structs for the same reason
# and never got the same treatment. They have it now, with the same property:
# an array whose kind already matches is the pointer itself, so it keeps its
# identity and its mutations, and only a mismatch pays for a rebuild.
#
# Where it came from: Rails' generated `<assoc>_ids` reader, which Roundhouse
# emits as `users.map { |r| r.id }` seeded `Array[Integer]`. `id` is nullable
# on the ActiveRecord base -- an unsaved record has none -- so every such
# reader on every model has this shape.
# spinel: rbs-seed-check
class Item
  attr_reader :id

  def initialize(id)
    @id = id
  end
end

class Other
  def initialize(id)
    @id = id
    @hidden = false
  end

  def id
    @hidden ? nil : @id
  end
end

class Rel
  def initialize(xs)
    @xs = xs
  end

  def to_a
    @xs
  end

  def map
    to_a.map { |x| yield x }
  end
end

class Room
  def users
    xs = []
    xs << Item.new(1)
    xs << Other.new(3)
    Rel.new(xs)
  end

  def user_ids
    users.map { |u| u.id }
  end
end

p Room.new.user_ids
