# str.each_char.with_index { } answers the String, and a break out of its
# block answers the break's value instead; the String is read once. The
# walk became (str.chars.each.with_index { }; str), whose tail took the
# break's place, so `break i` answered the String (and a later str[0, i]
# raised TypeError); a receiver that is no variable answered the chars.
str = 'abcdefgh'
index = str.each_char.with_index do |c, i|
  break i if i == 3
end
p index
p str[0, index]

p(str.each_char.with_index { |c, i| })
p(str.each_char.with_index(1) { |c, i| break [c, i] if c == "b" })
p(str.each_byte.with_index { |b, i| break b + i if i == 2 })
p("x\ny\n".each_line.with_index { |l, i| break l.chomp if i == 1 })
p("héllo".each_codepoint.with_index { |cp, i| break cp if i == 1 })

def word = 'spinel'
p(word.each_char.with_index { |c, i| break i if c == "n" })
p(word.each_char.with_index { |c, i| })
