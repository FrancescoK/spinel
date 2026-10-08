# A fresh builtin result keeps its own identity, including on a boxed receiver.
s = [+"--name", 1][ARGV.size]
prefix = s.delete_prefix("--")
suffix = s.delete_suffix("me")
a = prefix
b = suffix
prefix << "+"
suffix << "+"
p [s, a, b]
fresh = String.allocate
other = fresh
fresh << 65
p [fresh, other]
