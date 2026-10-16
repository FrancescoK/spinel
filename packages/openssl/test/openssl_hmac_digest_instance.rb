# OpenSSL::HMAC takes its algorithm as a Digest instance too, as CRuby's
# does (Aws::Sigv4::Signer passes OpenSSL::Digest.new("sha256")): by name or
# by class, either case, and whatever the instance was given to hash.
require "openssl"

key = "key"
data = "The quick brown fox"
by_name = OpenSSL::HMAC.hexdigest("SHA256", key, data)
puts by_name
puts OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), key, data) == by_name
puts OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new, key, data) == by_name
puts OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new("ignored"), key, data) == by_name
puts OpenSSL::HMAC.digest(OpenSSL::Digest.new("SHA256"), key, data).unpack1("H*") == by_name
puts OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("SHA1"), key, data)
puts OpenSSL::HMAC.digest(OpenSSL::Digest::SHA1.new, key, data).unpack1("H*")
