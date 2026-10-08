# spinel: share
# spinel: gc-minor
# Format operands keep the representation already held by mixed dispatch.
class PackBufferRest
  def pack(*args, **kw) = "rest:#{args}:#{kw}"
end
class PackBufferNamed
  def pack(fmt, buffer: nil) = "named:#{fmt}:#{buffer.inspect}"
end
def pack_buffer_format
  puts "format"
  +"C"
end
[[65], PackBufferRest.new, PackBufferNamed.new].each do |a|
  b = +"b"
  p a.pack(pack_buffer_format, buffer: b), b
end
[[65], PackBufferRest.new, PackBufferNamed.new].each do |a|
  p a.pack("C", buffer: nil)
end
[[65], PackBufferRest.new].each do |a|
  begin
    p a.pack("C", buffer: +"x", extra: 1)
  rescue ArgumentError => e
    p e.message
  end
end
def pack_buffer_keywords
  puts "keywords"
  {buffer: +"kw"}
end
[[65], PackBufferRest.new].each do |a|
  p a.pack(pack_buffer_format, **pack_buffer_keywords)
end
