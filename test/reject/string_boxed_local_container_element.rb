# A boxed local holding a String, put into an Array and changed through an
# element read: in CRuby the element is s, so s changes. The element is a
# copy of s's String and prepend raised NoMethodError: refused rather than
# compiled wrong.
k = ARGV.size
s = [+"xy", 1][k]
a = [s, 2]
a[0].prepend("^")
p s, a
