# A key slot no code ever fills: neither key class is constructed, so the
# census leaves `curve`, `private_key_bytes` and `to_der` no class to answer
# them. Those calls are still typed from the classes that define them, so the
# helpers return Strings as their other arms do and the program builds.
class ECKey
  attr_reader :curve, :private_key_bytes

  def initialize(curve, bytes)
    @curve = curve
    @private_key_bytes = bytes
  end
end

class RSAKey
  def to_der = "der"
end

class Context
  attr_accessor :key

  def initialize
    @key = nil
  end

  def self.key_curve(key) = key.is_a?(ECKey) ? key.curve : ""
  def self.key_bytes(key) = key.is_a?(ECKey) ? key.private_key_bytes : key.to_der

  def handshake(host)
    k = @key
    curve = k ? Context.key_curve(k) : ""
    bytes = k ? Context.key_bytes(k) : ""
    "#{host}: curve=#{curve.inspect} key=#{bytes.bytesize}"
  end
end

ctx = Context.new
puts ctx.handshake("example.org")
puts ctx.key.inspect
