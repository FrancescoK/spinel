# spinel: int64
# spinel: share
# spinel: gc-minor
# BER decoding keeps every magnitude bit, including across byte boundaries.
values = [0, 127, 128, 16383, 16384, 2**31 - 1, 2**31,
          2**63 - 1, 2**63, 2**64 - 1, 2**64, 2**70, 2**100 + 129,
          2**1000 + 127]
values.each do |value|
  encoded = [value].pack("w")
  p encoded.unpack1("w")
  p encoded.unpack("w*")
  p ("x" + encoded).unpack1("w", offset: 1)
end
p values.pack("w*").unpack("w*")
p [2**64].pack("w").unpack1("w")
(63..84).each do |bits|
  value = (2**64) << (bits - 64)
  p [value - 1, value, value + 1].pack("w3").unpack("w3")
end
# A boxed receiver and computed format keep the same boxed result.
encoded = [2**100 + 129].pack("w")
p [encoded, 1][0].unpack1("w" + "*")
p ("\x80".b * 20 + encoded).unpack("w*")
p ("\x80".b * 20 + "\x01".b).unpack("w*")
# Counts and following directives stop at complete BER values.
p [2**64, 7].pack("wC").unpack("wC")
p [2**64, 7].pack("wC").unpack("w0C")
p [2**64, 7].pack("wC").unpack1("w0")
p "".unpack("w2")
p "".unpack1("w")
p "\x81".b.unpack("w*")
p "\x81".b.unpack1("w")
p "\x01\x81".b.unpack("w*")
p ("\x81".b * 20).unpack("w*")
p ([2**100 + 129].pack("w") + "\x81".b * 20).unpack("w*")
