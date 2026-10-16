# `p` packs a count of elements, each a String's address (`p*` all of
# them), as CRuby does: it packed one pointer whatever the count (#9349).
# `P` packs one, its count the length of what it points to. Sizes are
# printed in pointers, so a 32-bit build answers the same.
W = [nil].pack("p").bytesize
[1, 2, 3].each do |n|
  a = (1..n).map { |i| "s#{i}" }.pack("p*")
  puts "n=#{n} pointers=#{a.bytesize / W}"
end
p ["a", "b", "c"].pack("p2").bytesize / W
p ["a", "b"].pack("pp").bytesize / W
p ["a", "b"].pack("P*").bytesize / W
p ["ab"].pack("P2").bytesize / W
p ["a", nil].pack("p*").bytesize / W
p ["a", nil].pack("p*").unpack("J*").last
p [nil, "b"].pack("pp").bytesize / W
p [].pack("p*").bytesize
begin
  ["a"].pack("p2")
rescue ArgumentError => e
  puts e.message
end
begin
  [1, "a"].pack("p*")
rescue TypeError => e
  puts e.message
end
