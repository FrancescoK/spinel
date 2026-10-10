# OpenSSL::HMAC with SHA-256 hashes a padded key block, then the message a
# 64-byte block at a time, then its tail. Every answer here is CRuby's: a
# message of every length across the first two blocks, a key shorter than a
# block, exactly a block and longer (a longer key is hashed down first), and
# a message long enough to stay in the block loop.
require "openssl"

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

key = noise(32, 3)
s = noise(130, 9)
(0..130).each { |n| puts OpenSSL::HMAC.hexdigest("SHA256", key, s[0, n]) }

[0, 1, 63, 64, 65, 131, 200].each { |k| puts OpenSSL::HMAC.hexdigest("SHA256", noise(k, 5), s) }

big = noise(100_003, 15)
puts OpenSSL::HMAC.hexdigest("SHA256", key, big)
puts OpenSSL::HMAC.digest("SHA256", key, big).unpack1("H*")
puts OpenSSL::HMAC.hexdigest("SHA256", noise(200, 7), big)
