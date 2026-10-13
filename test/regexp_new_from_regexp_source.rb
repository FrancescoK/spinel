# Regexp.new(regexp) compiles a copy of the regexp's source. The emitted
# copy took the source's length with sp_str_byte_len, which reads a
# String's tag byte; the source is the regexp engine's own C string, which
# has none, so the length came from the bytes before it, and fell back to
# strlen: a source holding a NUL was cut there. The argument was also
# evaluated once for the source and once more for the flags.
r = Regexp.new("a\0b")
c = Regexp.new(r)
p c.source == r.source, c.source.bytesize
p c.match?("a\0b"), c.match?("ac")
i = Regexp.new(Regexp.new("x\0y", Regexp::IGNORECASE))
p i.casefold?, i.match?("X\0Y"), i.source.bytesize
$made = 0
def made
  $made += 1
  /m+/
end
m = Regexp.new(made)
p $made, m.source, m.match?("mmm")
