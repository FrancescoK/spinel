# spinel: share
# spinel: gc-minor
# Cursor stars have count zero and consume no array elements.
["C@*C", "CX*C", "Cx*C", "CCX*", "Cx*"].each do |format|
  p [1, 2].pack(format).bytes
  buffer = +"ab"
  p [1, 2].pack(format, buffer: buffer).bytes
  p buffer.bytes
end
["@*", "X*", "x*", "@0", "X0", "x0"].each do |format|
  p [].pack(format).bytes
  buffer = +"ab"
  p [].pack(format, buffer: buffer).bytes
  p buffer.bytes
end
["C@*C", "CX*C", "Cx*C"].each do |format|
  p [1.0, 2.0].pack(format).bytes
end
["a@*a", "aX*a", "ax*a"].each do |format|
  p ["a", "b"].pack(format).bytes
end
["C@*a", "CX*a", "Cx*a"].each do |format|
  p [1, "b"].pack(format).bytes
end
p [1, 2].pack("Cx2CX1@4").bytes
