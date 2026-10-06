# [] and slice with a Regexp and a capture name (String or Symbol) on a
# String held in a mixed Array (a boxed receiver) answer that named capture
# of the first match, or nil, as on a String.
s = [+"Hello World", 1][0]
p s[/(?<x>W.)/, "x"], s[/(?<x>W.)/, :x], s.slice(/(?<x>W)(?<y>o)/, "y"), s[/(?<x>Z.)/, "x"]
x = s[/(?<w>l+)/, "w"]
p x, $~[0]
p s[/(W)(o)/, 2], s[/W\w+/]
n = [5, +"a"][0]
begin
  n[/(?<x>a)/, "x"]
rescue => e
  p e.class
end
