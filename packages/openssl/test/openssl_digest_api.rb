# The rest of OpenSSL::Digest's API: base64digest, the `!` forms that reset
# the object, length / size, #new, and the class methods, both a subclass's
# and OpenSSL::Digest's with the algorithm first.
require "openssl"
require "tmpdir"

["SHA256", "SHA1", "MD5"].each do |name|
  d = OpenSSL::Digest.new(name, "abc")
  puts d.base64digest
  puts d.base64digest("x")
  p d.hexdigest == OpenSSL::Digest.new(name).hexdigest

  d << "abc"
  p d.digest! == OpenSSL::Digest.new(name, "abc").digest
  p d.hexdigest == OpenSSL::Digest.new(name).hexdigest
  d << "abc"
  puts d.hexdigest!
  d << "abc"
  puts d.base64digest!
  puts d.hexdigest

  p [d.length, d.size, d.digest_length]

  d << "abc"
  fresh = d.new
  p fresh.class
  p fresh.name
  p fresh.hexdigest == OpenSSL::Digest.new(name).hexdigest
  p d.hexdigest == OpenSSL::Digest.new(name, "abc").hexdigest

  puts OpenSSL::Digest.hexdigest(name, "abc")
  p OpenSSL::Digest.digest(name, "abc") == OpenSSL::Digest.new(name, "abc").digest
  puts OpenSSL::Digest.base64digest(name, "abc")
end

puts OpenSSL::Digest::SHA256.base64digest("abc")
puts OpenSSL::Digest::SHA1.base64digest("abc")
puts OpenSSL::Digest::MD5.base64digest("abc")
p OpenSSL::Digest::SHA256.new.new.class

Dir.mktmpdir do |dir|
  path = File.join(dir, "data.bin")
  File.binwrite(path, "abc")
  puts OpenSSL::Digest.file(path, "SHA256").hexdigest
  puts OpenSSL::Digest.file(path, "MD5").hexdigest
end
