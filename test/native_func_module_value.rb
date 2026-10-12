# A module whose singleton methods a package binds with native_func
# (Digest::MD5.hexdigest) answers them when the module is held as a value:
# a local, an ivar picking one of several modules, a Hash or Array element,
# a method's return, and a boxed value.
require "digest/md5"
require "digest/sha1"
require "digest/sha2"
require "base64"
require "json"

h = Digest::MD5
puts h.hexdigest("x")

class Auth
  def initialize(algo)
    @h = algo == "MD5" ? Digest::MD5 : Digest::SHA1
  end

  def hex(s) = @h.hexdigest(s)
  def b64(s) = @h.base64digest(s)
  def raw_size(s) = @h.digest(s).bytesize
end

[Auth.new("MD5"), Auth.new("SHA1")].each do |a|
  puts a.hex("a:b:c"), a.b64("x"), a.raw_size("x")
end

[Digest::MD5, Digest::SHA1, Digest::SHA256].each { |d| puts d.hexdigest("abc") }
mods = { md5: Digest::MD5, sha256: Digest::SHA256 }
puts mods[:sha256].hexdigest("q")

def pick(k) = k ? Digest::SHA256 : Digest::MD5
puts pick(true).hexdigest("z"), pick(false).hexdigest("z")

boxed = [1, Digest::MD5, "s"][1]
puts boxed.hexdigest("boxed")

s = +"ab"
s << "cd"
puts h.hexdigest(s)
puts h.public_send(:hexdigest, "ps")
puts h.respond_to?(:hexdigest)

enc = Base64
puts enc.strict_encode64("hello"), enc.strict_decode64("aGVsbG8=")
j = JSON
puts j.generate({ "a" => [1, nil] })
puts j.parse('{"k": 2}')["k"]

# the constant call keeps the binding's own options
puts JSON.parse('{"k": 3}', symbolize_names: true)[:k]
# ... and so does one a module value in a local is read back as
puts j.parse('{"k": 4}', symbolize_names: true)[:k]
