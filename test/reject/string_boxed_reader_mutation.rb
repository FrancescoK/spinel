# A Struct member read through its reader is the member's own String. On a
# boxed receiver the reader's dispatch answers a copy, so the append through
# t would not reach the member: refused, not compiled with "value".
T = Struct.new(:text)
s = [T.new(+"value"), 0][0]
t = s.text
t << "!"
p s.text
