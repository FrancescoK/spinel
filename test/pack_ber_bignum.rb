# spinel: int64
# spinel: share
# spinel: gc-minor
# BER stores the whole nonnegative Integer, including every promoted bit.
[0, 127, 128, 16383, 16384, 2**63 - 1, 2**63, 2**64 - 1,
 2**64, 2**70, 2**100 + 129, 2**1000 + 127].each do |value|
  p [value].pack("w").bytes
  buffer = +"ab"
  p [value].pack("w", buffer: buffer).bytes
  p buffer.bytes
end
p [2**64].pack("w").bytes
(63..84).each do |bits|
  value = (2**64) << (bits - 64)
  p [value - 1, value, value + 1].pack("w*").unpack1("H*")
end
p [0, 127, 128, 2**64, 1].pack("w*").bytes
p [2**70 - 2**70, 2**70 - (2**70 - 128)].pack("w2").bytes
p [2**64, "z", 2**100].pack("waw").bytes
p [1.0, 127.9, 128.9, -0.5].pack("w*").bytes
p [2.0**64].pack("w").bytes
begin
  [1.0].pack("w2")
rescue ArgumentError => e
  p e.message
end
[-1, -(2**64), -(2**100)].each do |value|
  begin
    [value].pack("w")
  rescue ArgumentError => e
    p e.message
  end
  buffer = +"ab"
  begin
    [value].pack("w", buffer: buffer)
  rescue ArgumentError => e
    p e.message
  end
  p buffer.bytes
end
p [2**64].pack("w0").bytes
p [2**64 + 1].pack("Q<").bytes
