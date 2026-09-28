# A top-level ivar given Hash.new or Array.new, which no use types, is built
# at the slot's type instead of raising NoMethodError or failing the C build.
@iv = Hash.new
@iv["k"] = "v"
p @iv
@c = Hash.new(0)
"abca".each_char { |ch| @c[ch] += 1 }
p @c, @c["zz"]
@a = Array.new
@a << 1 << 2
p @a
@s = Array.new
@s << "x"
p @s
@cap = Hash.new(capacity: 3)
@cap[:a] = 1.5
p @cap
@blk = Hash.new { |h, k| h[k] = k * 2 }
p @blk[3], @blk
def top_m
  @m = Hash.new(7)
  @m[:q]
end
p top_m
