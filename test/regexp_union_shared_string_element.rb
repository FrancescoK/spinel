# Regexp.union of an Array holding a String a variable changes in place: the
# element is the String, read as its bytes when the union is made.
s = +"ht"
s << "tp"
a = [s, "https"]
p Regexp.union(*a).source
p Regexp.union(a).source
s << "x"
p a
