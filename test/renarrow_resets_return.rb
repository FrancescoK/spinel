# A self-referential ivar whose cycle runs through a method RETURN narrows.
#
# The optimistic re-narrow reset poly ivars, locals and params but not
# returns, and inference only widens -- so a return locked to poly could never
# narrow again, and `@s3 = rotl32(@s3, 11)` re-locked the ivar to poly on every
# re-run iteration however often the ivar itself was re-cleared. A whole PRNG
# stayed boxed on that: the lanes, the rotate, the draw, and every Float built
# from it.
#
# Both halves are needed to reach it: the ivar is SEEDED from a call and
# REASSIGNED from a call that takes the ivar. Either alone already narrowed.
class Rng
  MASK32 = 0xFFFFFFFF
  def initialize(seed)
    @s0 = finalize32(seed & MASK32)
    @s3 = finalize32(seed & MASK32)
  end
  def finalize32(x)
    z = x
  end
  def rotl32(x, k)
    ((x << k) | (x >> (32 - k))) & MASK32
  end
  def next_u32
    result = (rotl32((@s0 + @s3) & MASK32, 7) + @s0) & MASK32
    @s0 ^= @s3
    @s3 = rotl32(@s3, 11)
    result
  end
  def uniform
    a = next_u32 >> 5
    b = next_u32 >> 6
    (a * 67108864.0 + b) / 9007199254740992.0
  end
end
r = Rng.new(42)
p r.next_u32
p r.next_u32
p (r.uniform * 1_000_000).to_i
