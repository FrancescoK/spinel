# spinel: share
# spinel: gc-minor
# Every consuming directive raises when its next element is absent.
["C", "c", "n", "N", "v", "V", "s", "S", "l", "L", "q", "Q",
 "i", "I", "j", "J", "U", "w", "f", "F", "d", "D", "e", "E", "g", "G",
 "a", "A", "Z", "H", "h", "B", "b", "m", "M", "u",
 "a0", "a*", "m0", "M0", "u*"].each do |format|
  begin
    [].pack(format)
  rescue ArgumentError => e
    p e.message
  end
  buffer = +"ab"
  begin
    [].pack(format, buffer: buffer)
  rescue ArgumentError => e
    p e.message
  end
  p buffer.bytes
end
["CC", "C2", "n2", "w2", "f2", "Ca", "Ca0", "Cm0"].each do |format|
  begin
    [1].pack(format)
  rescue ArgumentError => e
    p e.message
  end
  begin
    [1].pack(format, buffer: +"ab")
  rescue ArgumentError => e
    p e.message
  end
end
begin
  [1.0].pack("d2")
rescue ArgumentError => e
  p e.message
end
begin
  [1.0].pack("C2")
rescue ArgumentError => e
  p e.message
end
begin
  ["a"].pack("aa")
rescue ArgumentError => e
  p e.message
end
begin
  ["a"].pack("aC")
rescue ArgumentError => e
  p e.message
end
begin
  [1, "a"].pack("CaC")
rescue ArgumentError => e
  p e.message
end
begin
  [nil].pack("C2")
rescue TypeError => e
  p e.message
end
p [].pack("C0w0f0C*w*f*x0").bytes
p [1].pack("C*").bytes
p [1.0].pack("C*").bytes
p ["a"].pack("C0a").bytes
p ["a"].pack("aC*").bytes
p [1, "a"].pack("CaC*").bytes
p [nil].pack("a0").bytes
