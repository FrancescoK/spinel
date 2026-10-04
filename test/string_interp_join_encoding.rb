# An interpolation and Array#join pick their encoding part by part as CRuby
# does: the first String part's, taken over by a later part's high bytes
# when everything before is ASCII; a binary part with high bytes keeps it.
b = "a".b
c = "\xff".b
u = "é"
n = 1
p "#{b}é".encoding, "#{b}x".encoding, "#{c}".encoding, "x#{b}".encoding, "x#{c}".encoding
p "#{n}#{b}".encoding, "#{n}x#{b}".encoding, "#{b}#{u}".encoding, "#{u}#{b}".encoding
p "#{b}#{c}".encoding, "#{c}#{b}x".encoding, "#{n}".encoding
p [b, "é"].join.encoding, [b, "x"].join.encoding, ["x", b].join.encoding, [c, "x"].join.encoding
p [b, u].join("-").encoding, [b, 1].join.encoding, [b, [c]].join.encoding
p ["é", "x"].join(b).encoding
x = [b, 1]
p x.join.encoding
