# encoding: binary
# Under a binary source encoding a literal holds the bytes written in it,
# raw or escaped (#9898): the PNG signature reads the same both ways, as
# in CRuby. Spinel warns that its Strings take UTF-8 as their encoding, so
# only the bytes are printed here.
RAW = "‰PNG\r\n\x1a\n"
ESCAPED = "\x89PNG\r\n\x1a\n"
p RAW.bytesize, RAW.bytes
p ESCAPED.bytes == RAW.bytes
p RAW.byteslice(1, 3)
p [RAW.getbyte(0), RAW.getbyte(7)]
