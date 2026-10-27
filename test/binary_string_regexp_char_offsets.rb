# A Regexp search over a binary String answers byte positions, since its
# characters are its bytes: rindex, index with a start and MatchData#begin
# counted the bytes as UTF-8, so "\xc3\xa9" was one character and each
# answered early. A UTF-8 String still answers in characters.
bin = "\x00\xc3\xa9\x00\x80z\xc3\xa9z".b
p bin.rindex(/[^\x00]/n), bin.rindex(/z/n), bin.rindex(/z/n, 7)
p bin.index(/z/n, 2), bin.index(/z/n)
m = bin.match(/z/n)
p m.begin(0), m.end(0), m.offset(0)
p "\xc3\xa9\xc3\xa9x".b.rindex(/\xa9/n), "\xc3\xa9x\xc3\xa9".b.rindex(/x/n, -1)

# the last non-zero byte of PCM-like data, as a trim reads it
pcm = ("\x00".b * 16) + [0x7f, 0xc3, 0xa9, 0x01].pack("C*") * 4 +
      ("\x00".b * 32)
p pcm.rindex(/[^\x00]/n), pcm.bytesize

text = "aéz-éz"
p text.rindex(/z/), text.rindex(/z/, 3), text.index(/z/, 3)
t = text.match(/-/)
p t.begin(0), t.offset(0)
