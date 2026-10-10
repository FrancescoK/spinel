# The deflate match search compares a candidate eight bytes at a time, and
# passes over one that cannot beat the match in hand. Both have to end where
# a byte at a time ends: on the first difference, at the 258 cap, or at the
# end of input.
#
# The compressed bytes are not pinned (zlib_test.rb says why). Every stream
# is round-tripped, and where a match has to be found the stream is held
# under what its unmatched bytes cost as literals plus the length and
# distance pairs of its matches: a match cut short, or a longer one passed
# over, goes past that.
require "zlib"

# Bytes with nothing in them to match, the same under every Ruby.
def noise(n, seed)
  x = seed
  out = []
  n.times do
    x = (x * 75 + 74) % 65537
    out << (x % 256).chr
  end
  out.join
end

# What `s` costs as fixed-Huffman literals, in bits.
def literal_bits(s)
  bits = 0
  s.each_byte { |b| bits += b < 144 ? 8 : 9 }
  bits
end

def round_trip?(s, level)
  Zlib.inflate(Zlib.deflate(s, level)).bytes == s.bytes
end

# `s` round-trips at each of `levels`, in no more than the zlib framing, one
# block's header and end, `unmatched` as literals and `pair_bits` of length
# and distance pairs.
def tight_at?(levels, s, unmatched, pair_bits)
  bits = 3 + literal_bits(unmatched) + pair_bits + 7
  levels.all? do |level|
    round_trip?(s, level) && Zlib.deflate(s, level).bytesize <= 2 + (bits + 7) / 8 + 4
  end
end

# The same at every search depth.
def tight?(s, unmatched, pair_bits)
  tight_at?([1, 6, 9], s, unmatched, pair_bits)
end

# The longest a length and distance pair gets, in bits.
LONGEST_PAIR = 31

# Inputs shorter than one comparison, and every tail length after it.
p (0..40).all? { |n| [1, 6, 9].all? { |level| round_trip?(noise(n, 3), level) } }
p (0..40).all? { |n| tight?("a" * n, "aaa", LONGEST_PAIR) }
p (0..40).all? { |n| tight?(("abc" * 14)[0, n], "abc", LONGEST_PAIR) }

# One copy of every length around the eight-byte steps and the 258 cap:
# running into the end of input, and stopped by a different byte. (The
# leading byte keeps the first copy off offset 0, which zlib never matches.)
[3, 4, 7, 8, 9, 15, 16, 17, 31, 32, 33, 63, 64, 65, 255, 256, 257, 258, 259,
 260, 300, 516, 517, 1000].each do |len|
  r = noise(len, 7)
  pairs = LONGEST_PAIR * ((len + 257) / 258)
  to_end = tight?("." + r + "#" + r, "." + r + "#", pairs)
  cut = tight?("." + r + "#" + r + "!", "." + r + "#!", pairs)
  puts "#{len} #{to_end} #{cut}"
end

# A copy that overlaps itself: the source of the comparison is closer than
# eight bytes to what it is compared with.
(1..17).each do |d|
  s = "." + noise(d, 5) * (600 / d + 2)
  puts "#{d} #{tight?(s, "." + noise(d, 5), LONGEST_PAIR * ((s.bytesize + 257) / 258))}"
end

# The longer candidate is the older one, behind a newer one that matches
# five bytes; then the other way round. Either way the long one is taken.
r = noise(120, 11)
p tight?("." + r + "|" + r[0, 5] + "|" + noise(40, 13) + r + ".",
         "." + r + "||" + noise(40, 13) + ".", LONGEST_PAIR * 2)
p tight?("." + r[0, 5] + "|" + noise(40, 13) + r + "|" + noise(40, 17) + r + ".",
         "." + r[0, 5] + "|" + noise(40, 13) + r + "|" + noise(40, 17) + ".", LONGEST_PAIR)

# The shortest match there is, three bytes, taken thirty times: each is a
# 12-bit pair (length 3, distance 4) where three literals are 24 bits or more.
s = "."
unmatched = "."
30.times do |j|
  t = noise(3, 31 + j)
  s += t + (65 + j).chr + t + (97 + j % 26).chr
  unmatched += t + (65 + j).chr + (97 + j % 26).chr
end
p tight?(s, unmatched, 12 * 30)

# A candidate one byte longer than the match in hand, behind it in the chain:
# 21 bytes at distance 43 after 20 bytes at distance 21. Taking the shorter
# one costs a literal each time. The pairs are 17 bits (the 20 bytes in the
# middle, at distance 22) and 18 bits. Not at level 1: there zlib settles
# for the first match of eight bytes.
s = "."
unmatched = "."
4.times do |j|
  t = noise(21, 61 + j)
  s += t + "|" + t[0, 20] + "~" + t + "!"
  unmatched += t + "|~!"
end
p tight_at?([6, 9], s, unmatched, (17 + 18) * 4)

# The only earlier copy sits at the window's edge, a byte inside it and a
# byte outside. zlib's own window is shorter, so only the round trip is common.
head = noise(200, 21)
[32767, 32768, 32769].each do |dist|
  s = head + noise(dist - 200, 23) + head + "z"
  p Zlib.inflate(Zlib.deflate(s)).bytes == s.bytes
end

# Past 65,536 bytes the chain entries are a ring, and an entry is taken over
# by the position a ring's length after it. Twelve 40-byte strings, each
# followed by its own first five bytes, come round again almost a window
# later, all of it past the ring's first lap. The search meets the five-byte
# copy first and gets to the whole string only through that copy's entry,
# written almost a window before: a ring half the window long has lost it by
# then, and the search stops at five bytes. The filler is a count in base
# 64, three digits a number and each digit in a range of its own, so no three
# bytes of it come twice; the strings are bytes from 192 up, which it has
# none of. The pairs are 16 bits (five bytes at distance 41) and 28 (forty
# bytes, 13 extra bits of distance).
def counting(from, count)
  out = []
  count.times do |j|
    c = from + j
    out << (c / 4096).chr
    out << (64 + c / 64 % 64).chr
    out << (128 + c % 64).chr
  end
  out.join
end

before = counting(0, 22_000)
between = counting(22_000, 10_633)
s = "." + before
unmatched = "." + before
again = ""
12.times do |j|
  t = ""
  noise(40, 101 + j).each_byte { |b| t += (b | 192).chr }
  s += t + "|" + t[0, 5] + "~"
  unmatched += t + "|~"
  again += t + "!"
end
p tight?(s + between + again, unmatched + between + "!" * 12, (16 + 28) * 12)
