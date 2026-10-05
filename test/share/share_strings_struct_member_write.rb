# Flag-only: without the flag (as on master) the C for these member writes does not compile.
# A Struct member the rule shares is written through a boxed receiver,
# by name and by key, and holds nil as nil.
T = Struct.new(:text)
s = [T.new(+"value"), 0][0]
p s.text
s.text = "again"
p s.text
p(s[:text] = nil); p s.text
s[0] = +"zero"; s.text << "0"
p s.text
s["text"] = nil; p s.text
