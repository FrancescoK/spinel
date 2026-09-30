# String#rpartition with an empty separator matches at the end of the
# string: [s, "", ""]. The other partitions are unchanged.
p "abc".rpartition("")
p "".rpartition("")
p "é日本".rpartition("")
p "a\0b".rpartition("")
e = ""
p "abc".rpartition(e)
def m(s) = s.rpartition("")
p m("xyz")
s = ["abc", 1][0]
p s.rpartition("")

# the neighbours
p "abcabc".rpartition("b")
p "abc".rpartition("z")
p "abab".rpartition("ab")
p "aaa".rpartition("aa")
p "abc".partition("")
