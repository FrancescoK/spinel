# String#[] with character positions on a string that is not all ASCII.
# The byte offset of a character is counted eight bytes at a time on valid
# UTF-8; every position below has to land on the same character as the
# one-character-at-a-time walk did, across word boundaries, with two-,
# three- and four-byte characters, and past the end.
strs = [
  "é" + "abcdefghij" * 5,
  "abcdefgé" + "hijklmnop",
  "日本語のテキスト、a" * 4,
  "a🍣bc🍣def🍣ghij🍣klmnopq🍣rs",
  "ñandú\0ñandú\0ñandú",
  "1234567é",
  "12345678é",
  "é",
]
strs.each do |s|
  len = s.length
  all = []
  i = -len - 1
  while i <= len + 1
    all << s[i].inspect
    i += 1
  end
  puts all.join(" ")
  pairs = []
  [0, 1, 7, 8, 9, len - 3, len - 1, len, len + 1].each do |st|
    pairs << s[st, 3].inspect
    pairs << s[st..st + 4].inspect
  end
  puts pairs.join(" ")
  p s[-5, 4]
  p s[len / 2..]
end

# A long mostly-ASCII string read at many positions near its end.
long = "é" + "abcdefghij" * 3000
acc = 0
k = 0
while k < 2000
  acc += long[30_000 - (k % 17), 3].bytesize
  k += 1
end
p acc
