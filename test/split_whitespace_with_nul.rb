# String#split on whitespace (no argument, nil or " ") treats a NUL as an
# ordinary character, as CRuby does; it used to stop reading at the first one.
nul = 0.chr
s = "ab" + nul + "cd ef" + nul
p s.split
p s.split(" ")
p s.split(nil)
p s.split(" ", 2)
p s.split(" ", -1)
p s.split(" ", 1)
p "ab\0cd".split
p " a\0 b ".split
p "a\0b c\0d".split(" ", 2)
p "a b\0c".split
p "\0".split
p "\0 \0".split
p "  \0  ".split
p "a\0".split(" ", -1)
p "a \0".split(" ", -1)
p "\0\0 x".split

b = [s, "x y"]
p b.map { |v| v.split }
p b[0].split(" ")
t = "p\0q r"
words = t.split
p words, words.size, words[0].size

# a separator variable, a limit and a block go the same way; a separator that holds
# a NUL after the space is not the single space
sep = " "
p s.split(sep), s.split(sep, 2)
p s.split(nil, 2)
words = []
s.split { |w| words << w }
p words
p "a \0".split(" \0"), "a \0".split(" \0", -1)
seps = []
"a \0b \0".split(" \0") { |w| seps << w }
p seps
nsp = " \0"
p " \0".split(nsp), "a \0 \0".split(nsp), "a b".split(nsp)

# the separator forms that already handled NUL are unchanged
p "a\0b\0c".split("\0")
p "a\0b".split("")
p "a\0b c".split(/\s/)
