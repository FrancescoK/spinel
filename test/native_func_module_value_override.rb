# A program's own singleton method on a module beats the package's
# native_func of that name, on the constant and on the module as a value.
require "digest/md5"
require "digest/sha1"

class << Digest::MD5
  def hexdigest(s) = "mine:" + s
end

puts Digest::MD5.hexdigest("a")
[Digest::SHA1, Digest::MD5].each { |h| puts h.hexdigest("b") }

# ... and so does one in `class << self` in the module's own body, after
# its native_func
module Hasher
  unless RUBY_ENGINE == "spinel"
    def self.native_lib(*) = nil
    def self.native_func(*) = nil
  end

  native_lib "digest"
  native_func :hexdigest, [:string], :cstring, "sp_crypto_md5_hex"

  class << self
    def hexdigest(s) = "own:" + s
  end
end

puts Hasher.hexdigest("c")
puts [Hasher, 1][0].hexdigest("d")
