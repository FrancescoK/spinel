# String#split("", limit) ends in one empty field when the limit leaves room
# for it: a negative limit, or a positive one larger than the number of
# characters, unless the String is empty.
["hi!", "", "a", "é日"].each do |s|
  [-2, -1, 0, 1, 2, 3, 4, 5].each do |n|
    p [s, n, s.split("", n)]
  end
end
e = ""
x = ["hi!", 1][0]
p x.split(e, -1)
p x.split(e, 4)

# the neighbours
p "a,b,".split(",", -1)
p "a,b,".split(",", 5)
p "".split(",", -1)
p " a b ".split(" ", -1)
p "a b".split(nil, -1)

# a NUL byte in the receiver or the separator
p "\0a".split("", -1)
p "\0".split("", -1)
p "a\0b".split("\0", -1)
p "a\0b\0".split("\0", -2)
p "x\0".split("\0", -1)
p "abc".split("\0", -1)
p "a\0xb".split("\0x", -1)
