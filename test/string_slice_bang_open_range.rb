# String#slice! with a beginless or endless Range, as a value and as a
# statement: a beginless one starts at the beginning, where it answered nil
# and removed nothing, and an endless one runs to the end, where its length
# overflowed as a statement.
s = String.new("abcdef")
p s.slice!(..1), s
s = String.new("abcdef")
p s.slice!(...2), s
s = String.new("abc")
p s.slice!(..-1), s
s = String.new("abc")
p s.slice!(nil..nil), s
s = String.new("abcdef")
p s.slice!(..-3), s

s = String.new("abcdef")
s.slice!(..1)
p s
s = String.new("abcdef")
s.slice!(nil..-3)
p s
s = String.new("abcdef")
s.slice!(2..)
p s
s = String.new("abcdef")
s.slice!(-2..)
p s
@s = String.new("xyz")
p @s.slice!(..0), @s
