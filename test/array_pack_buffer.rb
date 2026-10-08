# spinel: share
# spinel: gc-minor
# The keyword buffer receives the bytes with either receiver representation.
# Read each buffer directly; the default build may copy the returned String.
class PackBufferString
  def value = +"ab"
end
class PackBufferNumber
  def value = 7
end
def pack_buffer_array(n)
  n == 0 ? [65] : 7
end

plain = String.new("ab")
r = [65].pack("C", buffer: plain)
p plain, r
[66].pack("C", buffer: (plain))
p plain
empty = +""
p [66].pack("C", buffer: empty)
p empty
p [67].pack("C", buffer: +"ab")

sources = [PackBufferString.new, PackBufferNumber.new]
b = sources[0].value
p [65].pack("C", buffer: b)
p b
p [65].pack("C", buffer: sources[0].value)

b = +"ab"
p pack_buffer_array(0).pack("@1C", buffer: b)
p b
b = sources[0].value
p pack_buffer_array(0).pack("XC", buffer: b)
p b

b = +"ab"
p [65, 66].pack("C@1C@5", buffer: b)
p b.bytes
b = +"ab"
p [].pack("@1", buffer: b)
p b
b = +"ab"
p [65.0].pack("C", buffer: b)
p b
b = +"ab"
p ["x\0y"].pack("a*", buffer: b)
p b.bytes
b = +"ab"
p [65, "z"].pack("Ca", buffer: b)
p b

b = +"é"
p [65].pack("C", buffer: b)
p b.encoding
b = +"ab".b
p [233].pack("U", buffer: b).bytes
p b.encoding

class PackBufferHolder
  def initialize
    @buffer = +"ab"
  end
  def run
    p [65].pack("C", buffer: @buffer)
    p @buffer
  end
end
PackBufferHolder.new.run

class PackBoxedBufferHolder
  def initialize(value)
    @buffer = value
  end
  def run
    p pack_buffer_array(0).pack("C", buffer: @buffer)
    p @buffer
  end
end
PackBoxedBufferHolder.new(sources[0].value).run

b = nil
p [65].pack("C", buffer: b)
p b
boxed_buffers = [nil, "ab", 7]
p pack_buffer_array(0).pack("C", buffer: boxed_buffers[0])
begin
  [65].pack("C", buffer: boxed_buffers[1])
rescue FrozenError
  puts "boxed frozen buffer FrozenError"
end
begin
  [65].pack("C", buffer: 7)
rescue TypeError
  puts "typed buffer TypeError"
end
begin
  pack_buffer_array(0).pack("C", buffer: sources[1].value)
rescue TypeError
  puts "boxed buffer TypeError"
end
begin
  [65].pack("C", buffer: "ab")
rescue FrozenError
  puts "literal buffer FrozenError"
end
b = +"ab"
b.freeze
begin
  pack_buffer_array(0).pack("C", buffer: b)
rescue FrozenError
  puts "frozen buffer FrozenError"
end

def pack_order_array
  puts "receiver"
  [65]
end
def pack_order_format
  puts "format"
  +"C"
end
def pack_order_buffer
  puts "buffer"
  +"ab"
end
p pack_order_array.pack(pack_order_format, buffer: pack_order_buffer)

class UserBufferPack
  def pack(format, buffer:)
    +"user"
  end
end
[[65], UserBufferPack.new, nil, 7].each do |a|
  b = +"ab"
  begin
    p a.pack("C", buffer: b)
    p b
  rescue NoMethodError
    puts "receiver NoMethodError"
  end
end
[[65], UserBufferPack.new].each do |a|
  p a.pack("C", buffer: pack_order_buffer)
end
