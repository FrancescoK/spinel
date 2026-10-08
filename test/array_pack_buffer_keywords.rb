# spinel: share
# spinel: gc-minor
# A splatted buffer writes back to its Hash; unknown keys raise after evaluation.
opts = {buffer: +"op"}
p [66].pack("C", **opts), opts
p [65].pack("C", **{buffer: +"lit"})
p [65].pack("C", **nil)
p [65].pack("C", **{})
def pack_keyword_effect
  puts "keyword"
  +"x"
end
begin
  [67].pack("C", buf: pack_keyword_effect)
rescue ArgumentError => e
  p e.message
end
begin
  [67].pack("C", buffer: +"x", extra: 1)
rescue ArgumentError => e
  p e.message
end
begin
  [67].pack("C", **{extra: 1, buf: +"x"})
rescue ArgumentError => e
  p e.message
end
begin
  [67].pack("C", **{"buffer" => +"x"})
rescue ArgumentError => e
  p e.message
end
b = +"last"
p [65].pack("C", **{}, buffer: b), b
h = {buffer: +"first"}
p [66].pack("C", **h, **{}), h
other = {buffer: +"other"}
p [67].pack("C", **h, **other), h, other
opts = Hash.new(+"unused")
p [65].pack("C", **opts), opts
