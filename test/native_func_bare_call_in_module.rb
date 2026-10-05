# A bare call to a native_func inside its module's singleton methods is
# the module function, as Hasher.hexdigest is. It was refused.
module Hasher
  unless RUBY_ENGINE == "spinel"
    require "digest"
    def self.native_lib(*) = nil
    def self.native_func(*) = nil
    def self.hexdigest(data) = Digest::SHA256.hexdigest(data)
  end

  native_lib "digest"
  native_func :hexdigest, [:string], :cstring, "sp_crypto_sha256_hex"

  def self.twice_explicit(data) = Hasher.hexdigest(Hasher.hexdigest(data))
  def self.twice(data) = hexdigest(hexdigest(data))
end

p Hasher.twice_explicit("x")
p Hasher.twice("x")
