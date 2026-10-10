# Digest::SHA256 takes its input a 64-byte block at a time, on the CPU's SHA
# instructions where it has them and in portable C where it does not. Every
# answer here is CRuby's: the FIPS 180-4 examples, every length across the
# first two blocks (so every shape of the padding, which fits beside the
# data up to 55 bytes into a block and takes a block of its own from 56),
# inputs long enough to stay in the block loop, and a digest of digests.
require "digest"

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

puts Digest::SHA256.hexdigest("abc")
puts Digest::SHA256.hexdigest("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq")
puts Digest::SHA256.hexdigest("abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu")
puts Digest::SHA256.hexdigest("a" * 1_000_000)

s = noise(130, 9)
(0..130).each { |n| puts Digest::SHA256.hexdigest(s[0, n]) }

big = noise(100_003, 15)
puts Digest::SHA256.hexdigest(big)
puts Digest::SHA256.base64digest(big)
puts Digest::SHA256.digest(big).unpack1("H*")
puts Digest::SHA256.hexdigest("\x00" * 4099)
puts Digest::SHA256.hexdigest("\xff" * 4099)

# Two digests side by side are exactly one block, and their digest the next
# pair's half: each round's state is the one before it, 200 times over.
d = Digest::SHA256.digest("")
200.times { d = Digest::SHA256.digest(d + d) }
puts d.unpack1("H*")
