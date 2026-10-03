# `s.gsub!(pattern)` with no block answers an Enumerator over the matches,
# like gsub's; a stored one's each block is the edit. It failed to compile
# (the Enumerator landed in a String slot). Both name the pattern in their
# #inspect, and neither has a size.
s = "abcb".dup
e = s.gsub!(/b/)
p e.class
p e
p e.size
r = e.each { |m| m.upcase }
p r
p s
t = "xyz".dup
e2 = t.gsub!("q")
p e2
p e2.each { "Z" }
p t
p "abcb".gsub(/b/)
p "abcb".gsub("c").size
re = /c/
p "abcb".gsub(re).to_a
u = "aaa".dup
u.gsub!(/a/, "b")
p u
w = "abcb".dup
w.gsub!(/b/)
p w
x = [w.gsub!(/c/)]
p x[0].class
