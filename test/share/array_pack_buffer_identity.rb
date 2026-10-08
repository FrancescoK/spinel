# spinel: gc-minor
# Pack returns its buffer, including through a boxed receiver or argument.
def pack_identity_array(n)
  n == 0 ? [65] : 7
end
class PackIdentityString
  def value = +"ab"
end
class PackIdentityNumber
  def value = 7
end
typed = +"ab"
r = [65].pack("C", buffer: (typed))
r << "!"
p typed
local = +"ab"
r = pack_identity_array(0).pack("@1C", buffer: local)
r << "!"
p local
sources = [PackIdentityString.new, PackIdentityNumber.new]
b = sources[0].value
r = [65].pack("C", buffer: b)
r << "!"
p b
b = sources[0].value
r = pack_identity_array(0).pack("C", buffer: b)
r << "!"
p b
class PackIdentityHolder
  def initialize
    @buffer = +"ab"
  end
  def run
    r = [65].pack("C", buffer: @buffer)
    r << "!"
    p @buffer
  end
end
PackIdentityHolder.new.run
class PackIdentityBoxedHolder
  def initialize(value)
    @buffer = value
  end
  def run
    r = pack_identity_array(0).pack("C", buffer: @buffer)
    r << "!"
    p @buffer
  end
end
PackIdentityBoxedHolder.new(sources[0].value).run

class UserIdentityPack
  def pack(format, buffer:)
    +"user"
  end
end
[[65], UserIdentityPack.new].each do |a|
  b = +"ab"
  r = a.pack("C", buffer: b)
  r << "!"
  p b
end
