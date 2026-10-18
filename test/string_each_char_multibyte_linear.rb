# String#each_char with a block walks the string once. Each turn took the
# i-th character by counting from the start of the string, so a string with
# one multibyte character took time quadratic in its length: the long case
# below ran past the test's time budget.
s = "é" + "a" * 300_000
count = 0
s.each_char { |c| count += 1 if c == "a" }
puts count

# The characters themselves: multibyte, NUL, and a three- and four-byte one.
out = []
"aé\0b日🍣".each_char { |c| out << c }
p out
p out.map(&:bytesize)

# A BINARY string yields one byte per character, each still BINARY.
bin = "é\xff".b
bs = []
bin.each_char { |c| bs << c }
p bs
p bs.map(&:encoding)

# A malformed byte is a character of its own.
bad = []
"é\xffa".each_char { |c| bad << c }
p bad

# next and break inside the block.
seen = []
"héllo wörld".each_char do |c|
  next if c == "l"
  break if c == " "
  seen << c
end
p seen

# A block without a parameter still runs once per character.
n = 0
"日本語".each_char { n += 1 }
p n

# A block parameter that also holds other kinds of values.
kinds = []
"aé".each_char { |c| c = c.bytesize if c == "é"; kinds << c }
p kinds

# chars with a block walks the same way.
cs = []
"ñandú".chars { |c| cs << c }
p cs

# The empty string yields nothing.
"".each_char { |c| p c }
puts "done"
