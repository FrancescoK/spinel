# A user #to_json answer is the document, byte for byte: JSON.generate hands it
# through without reading it as C text, so a NUL inside it survives at top
# level and nested alike.
# spinel: wasm
require "json"
NUL = 0.chr
class Raw
  def to_json(*) = "\"ab" + NUL + "cd\""
end
t = JSON.generate(Raw.new)
p [t.bytesize, t.bytes]
n = JSON.generate([Raw.new, { "k" => Raw.new }])
p [n.bytesize, n.bytes.count(0)]
# (a plain String with a NUL inside is a different path, the escaper, and is
# not pinned here)
