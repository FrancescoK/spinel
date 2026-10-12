# A program's own singleton method on a module beats the package's
# native_func of that name, on the constant and on the module as a value.
require "digest/md5"
require "digest/sha1"

class << Digest::MD5
  def hexdigest(s) = "mine:" + s
end

puts Digest::MD5.hexdigest("a")
[Digest::SHA1, Digest::MD5].each { |h| puts h.hexdigest("b") }
