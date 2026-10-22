# OpenSSL::Digest fed in pieces answers the digest of the whole input: the
# RFC 1321 (MD5) and RFC 6234 (SHA-1, SHA-256) test vectors, split at every
# size around the 64-byte block, and #digest, #reset, #dup and #file around
# the kept state.
require "openssl"
require "tmpdir"

VECTORS = [
  "",
  "a",
  "abc",
  "message digest",
  "abcdefghijklmnopqrstuvwxyz",
  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789",
  "1234567890" * 8,
  "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq",
  "0123456701234567012345670123456701234567012345670123456701234567" * 10,
]
SPLITS = [1, 3, 55, 56, 63, 64, 65, 1000]

def fed(name, data, size)
  d = OpenSSL::Digest.new(name)
  i = 0
  while i < data.bytesize
    d.update(data.byteslice(i, size))
    i += size
  end
  d.hexdigest
end

["MD5", "SHA1", "SHA256"].each do |name|
  VECTORS.each do |data|
    whole = OpenSSL::Digest.new(name).hexdigest(data)
    agree = SPLITS.all? { |size| fed(name, data, size) == whole }
    puts "#{name} #{data.bytesize} #{whole} #{agree}"
  end

  million = "a" * 1_000_000
  puts "#{name} million #{fed(name, million, 4093)} #{fed(name, million, 65_536) == fed(name, million, 1000)}"

  d = OpenSSL::Digest.new(name)
  d << "ab"
  first = d.hexdigest
  p first == d.hexdigest
  d << "c"
  p d.hexdigest == OpenSSL::Digest.new(name).hexdigest("abc")
  copy = d.dup
  copy << "d"
  p d.hexdigest == OpenSSL::Digest.new(name).hexdigest("abc")
  p copy.hexdigest == OpenSSL::Digest.new(name).hexdigest("abcd")
  p d.reset.hexdigest == OpenSSL::Digest.new(name).hexdigest("")
  p OpenSSL::Digest.new(name, "abc").hexdigest == OpenSSL::Digest.new(name).hexdigest("abc")
end

Dir.mktmpdir do |dir|
  path = File.join(dir, "big.bin")
  data = (0...256).map(&:chr).join.b * 12_288
  File.binwrite(path, data)
  p File.size(path)
  p OpenSSL::Digest::SHA256.file(path).hexdigest == OpenSSL::Digest::SHA256.hexdigest(data)
  p OpenSSL::Digest::SHA1.file(path).hexdigest == OpenSSL::Digest::SHA1.hexdigest(data)
  p OpenSSL::Digest::MD5.file(path).hexdigest == OpenSSL::Digest::MD5.hexdigest(data)
end
