# The same contradiction with a user OBJECT in the slot. The shared family rule
# leaves objects alone because the emitter knows conversions for many of them,
# but a seeded return converts nothing: a class defining #to_h and #to_hash
# lands in the Hash slot exactly like one defining neither. Two objects stay
# unjudged, though -- a subclass in an ancestor's slot is legitimate.
# spinel: rbs-seed-contradicted-return
class P
  def to_h
    { a: 1 }
  end

  def to_hash
    { a: 1 }
  end
end

class C
  def f
    P.new
  end
end

puts C.new.f.inspect
