# spinel: share
# A user class owning a String iterator's name (packages/stringio's
# StringIO#each_char) made every block-taking call of that name on a
# run-time-typed receiver a dispatch over the user classes alone, and a
# String reaching it raised NoMethodError for a method String has (#5083,
# the block-taking sibling of #4816). A user object still takes its own.

class Chars
  def each_char
    yield "z"
    self
  end

  def each_byte
    yield 1
    self
  end

  def each_line
    yield "l"
    self
  end

  def each_grapheme_cluster
    yield "g"
    self
  end
end

def count_chars(s)
  n = 0
  s.each_char { |ch| n += 1 }
  n
end

def sum_bytes(s)
  t = 0
  s.each_byte { |b| t += b }
  t
end

def lines(s)
  out = []
  s.each_line { |l| out << l }
  out
end

def graphemes(s)
  out = []
  s.each_grapheme_cluster { |g| out << g }
  out
end

a = ["ab", 1]
puts count_chars(a[0])
p sum_bytes(a[0])
p lines(["x\ny\n", 1][0])
p graphemes(["ab", 1][0])

c = [Chars.new, 1][0]
puts count_chars(c)
p sum_bytes(c)
p lines(c)
p graphemes(c)

m = +"q"
m << "r"
puts count_chars([m, 1][0])
