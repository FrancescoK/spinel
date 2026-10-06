# A boxed local holding a String, put into an Array whose iterator block
# changes the element: in CRuby the element is s, so s changes. The block
# parameter is a copy of s's String and the change was lost ("xy"):
# refused rather than compiled wrong.
k = ARGV.size
s = [+"xy", 1][k]
[s].each { |e| e.insert(0, "<") }
[s].map { |e| e.concat(">") }
p s
