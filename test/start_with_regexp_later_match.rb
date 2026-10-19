# start_with?(re) tries the pattern at the start only: a match that
# begins later answers false and leaves $~ nil, whichever way the
# Regexp is held.
s = "abc"
"zz" =~ /z/
p s.start_with?(/b/), $~
p s.start_with?(/a(b)/), $~, $1
re = Regexp.new("c")
p s.start_with?(re), $~
p s.start_with?(/x/, /b/), $~
p s.start_with?(/b/, "a"), $~
p s.start_with?(/a\Kb/), $~
p :abc.start_with?(/c/), $~
v = [re, "q"][0]
"zz" =~ /z/
p "abc".start_with?(v), $~
w = [1, "abc"][1]
p w.start_with?(v), $~
p w.start_with?(/b/), $~
p w.start_with?(/ab/), $~
