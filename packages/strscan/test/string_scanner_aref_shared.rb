# spinel: share
# StringScanner#[] answers a new String, one no other name holds, so under
# --share-strings it can be named twice and changed in place: tzinfo's POSIX
# time-zone parser reads its captures this way. Undeclared, the capture was
# refused ("the String the value of `[]` hands on as a variable's write ...
# would hand on a copy").
require "strscan"
s = StringScanner.new("12:34")
s.scan(/(\d+):(\d+)/)
a = s[1]
b = a
b << "!"
p a, b, a.equal?(b)
c = s[2]
p c, s[1], s[3]
