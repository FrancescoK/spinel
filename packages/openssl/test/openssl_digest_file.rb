# OpenSSL::Digest::<Algo>.file hashes the bytes of a file named by a path or
# by an object with to_path (a File or a Tempfile, read again from its path),
# and answers the digest object, so hexdigest / digest / update chain on it.
require "openssl"
require "tempfile"
require "tmpdir"

Dir.mktmpdir do |dir|
  path = File.join(dir, "small.bin")
  File.binwrite(path, "hello\x00world\n".b)

  p OpenSSL::Digest::SHA256.file(path).hexdigest
  p OpenSSL::Digest::SHA1.file(path).hexdigest
  p OpenSSL::Digest::MD5.file(path).hexdigest
  p OpenSSL::Digest::SHA256.file(path).digest.bytesize
  p OpenSSL::Digest::SHA256.file(path).name
  p OpenSSL::Digest::SHA256.file(path).update("more").hexdigest
  p OpenSSL::Digest::SHA256.new("abc").file(path).hexdigest

  File.open(path) do |f|
    f.read(3)
    p OpenSSL::Digest::SHA256.file(f).hexdigest
    p f.pos
  end

  t = Tempfile.new("digest")
  t.write("tempfile bytes")
  t.flush
  p OpenSSL::Digest::SHA256.file(t).hexdigest
  t.close!

  big = File.join(dir, "big.bin")
  data = "0123456789abcdef".b * 98_304
  File.binwrite(big, data)
  p File.size(big)
  p OpenSSL::Digest::SHA256.file(big).hexdigest
  p OpenSSL::Digest::SHA256.file(big).hexdigest == OpenSSL::Digest::SHA256.hexdigest(data)

  begin
    OpenSSL::Digest::SHA256.file(File.join(dir, "missing.bin"))
  rescue SystemCallError => e
    p e.class
  end
end
