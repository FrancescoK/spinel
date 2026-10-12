# A `scan` block's match is a new String, so a match the block changes in
# place and keeps (or breaks out with) is that String itself. The subject
# may be a local that holds an element of an Array literal, and a local the
# scan's own value goes to (the receiver, or the match a `break` hands out)
# is a name the block cannot reach the subject by while the scan runs.
s = [+"abc", 1].first
s.scan(/./) { |m| m << "!"; puts m }
acc = []
s.scan(/./) { |m| m << "?"; acc << m }
p acc, s

t = [1, +"xyz"].last
kept = []
t.scan(/./) { |m| m << "#"; kept << m }
p kept, t

u = +"ab"
x = u.scan(/./) { |m| break m }
x << "!"
p x, u
