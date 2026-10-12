require "digest"

path = "/tmp/spinel_digest_file_test.bin"
File.binwrite(path, "hello\x00world\n".b)
d = Digest::MD5.file(path)
puts d.hexdigest
puts d.to_s
puts d.base64digest
puts Digest::SHA256.file(path).hexdigest
puts Digest::SHA1.file(path).hexdigest[0, 10]
puts Digest::MD5.file(path).digest.bytesize
File.delete(path)
