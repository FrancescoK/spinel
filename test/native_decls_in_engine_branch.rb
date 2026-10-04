# native_lib / native_func inside an engine branch of a module body are
# registered: the settled branch runs in place. They were not visited.
module Hasher
  if RUBY_ENGINE == "spinel"
    native_lib "digest"
    native_func :hexdigest, [:string], :cstring, "sp_crypto_sha256_hex"
  else
    require "digest"
    def self.hexdigest(data) = Digest::SHA256.hexdigest(data)
  end
end

p Hasher.hexdigest("x")
