# A method copies a String out of its argument, appends to the copy and
# returns it; the answer keys an empty Hash. While the argument settles,
# the copy's `<<` is not yet known to be String#<<, and reading it as an
# Array push left the Hash boxed for good (#8783).
def word(src)
  buf = src.byteslice(0, 3)
  buf << "x"
  buf
end

def word2(src)
  buf = src.dup
  buf << "y"
  buf
end

index = {}
index[word("icn")] = 0
index[word("gmp")] = 1
p index
p index["icnx"], index["gmpx"]

codes = []
codes << word2("nrt")
by = {}
by[codes[0]] = 2
p by, codes
