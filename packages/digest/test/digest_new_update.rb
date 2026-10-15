require "digest"

# Digest::<Algo>.new collects what update and << are given and answers the
# digest of all of it, as CRuby's incremental instance does.
sha = Digest::SHA256.new
sha << "a" << "b"
sha.update("c\x00d".b)
puts sha.hexdigest
puts sha.hexdigest == Digest::SHA256.hexdigest("abc\x00d".b)
puts sha.base64digest
puts sha.digest.bytesize
puts sha.reset.hexdigest == Digest::SHA256.hexdigest("")
puts Digest::SHA1.new.update("ab").hexdigest
puts (Digest::MD5.new << "ab").hexdigest
