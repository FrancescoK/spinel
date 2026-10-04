# native_lib / native_func declared inside a RUBY_ENGINE branch of a module
# body are registered, and a native_func is a module function of its module:
# a bare call to it in the module's singleton methods reaches it (#7205).
module Hasher
  if RUBY_ENGINE == "spinel"
    native_lib "digest"
    native_func :hexdigest, [:string], :cstring, "sp_crypto_sha256_hex"
  else
    require "digest"
    def self.hexdigest(data) = Digest::SHA256.hexdigest(data)
  end

  def self.twice_explicit(data) = Hasher.hexdigest(Hasher.hexdigest(data))
  def self.twice(data) = hexdigest(hexdigest(data))
end

p Hasher.hexdigest("x")
p Hasher.twice_explicit("x") == Hasher.twice("x")
p Hasher.twice("x")
