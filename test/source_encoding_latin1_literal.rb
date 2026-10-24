# encoding: ISO-8859-1
# Under a Latin-1 source encoding the raw byte 0xE9 in a literal is
# accepted and kept as one byte (#9898), as in CRuby. Spinel warns that its
# Strings take UTF-8 as their encoding, so only the bytes are printed here.
CAFE = "café"
p CAFE.bytesize, CAFE.bytes
p CAFE.getbyte(3).to_s(16)
