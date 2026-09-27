# A native class's writer on a boxed receiver, used as an assignment
# (StringScanner#pos= on a scanner read out of a container), sets the value
# and answers it, as on a typed scanner.
require "strscan"
s = [StringScanner.new("abc123"), 0][0]
s.pos = 1
p s.pos
p(s.pos = 3)
p s.rest
x = (s.pos = 0)
p [x, s.rest]
n = 2
p((s.pos = n) + 1)
p s.rest
