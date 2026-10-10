# Zlib.crc32 takes its input eight bytes a step and the rest a byte at a
# time. Every answer here is CRuby's: the standard check value, every
# length across the first steps (so every tail length), an input long
# enough to stay in the eight-byte loop, and a checksum carried on from
# one string to the next at every split.
require "zlib"

# Bytes with no pattern, the same under every Ruby.
def noise(n, seed)
  x = seed
  out = []
  n.times do
    x = (x * 75 + 74) % 65537
    out << (x % 256).chr
  end
  out.join
end

p Zlib.crc32("123456789")

s = noise(72, 9)
(0..72).each { |n| p Zlib.crc32(s[0, n]) }

p Zlib.crc32(noise(100_000, 15))
p Zlib.crc32("\x00" * 4099)
p Zlib.crc32("\xff" * 4099)

# Carried on: the second call starts from the first one's value, with the
# split at every offset, so both halves start and end anywhere in a step.
whole = Zlib.crc32(s)
p (0..72).all? { |n| Zlib.crc32(s[n, 72 - n], Zlib.crc32(s[0, n])) == whole }

# The same checksum closes a gzip stream, and gunzip checks it.
big = noise(20_011, 27)
p Zlib.gunzip(Zlib.gzip(big)).bytes == big.bytes

# And refuses a stream whose trailer carries another value.
g = Zlib.gzip(big)
wrong = g[0, g.bytesize - 8] + "wxyz" + g[g.bytesize - 4, 4]
begin
  Zlib.gunzip(wrong)
  puts "no raise"
rescue Zlib::Error
  puts "Error"
end
