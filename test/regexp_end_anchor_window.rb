# A pattern whose every branch ends at \z, \Z or $ within a bounded number of
# bytes is tried only that far before where the assertion can pass. The
# answers are the ones trying every position gives: where the match starts,
# what the groups hold, $~, and what the String methods built on a search
# answer.

# \z: the whole subject is not walked, but the match is the leftmost one
p "foo bar  ".match?(/[[:blank:]]\z/)
p "foo bar\n".match?(/[[:blank:]]\z/)
p "foo bar \t" =~ /[[:blank:]]+\z/
p "foo bar \t" =~ /[[:blank:]]{1,2}\z/
p "aaaa" =~ /a{2,3}\z/
p "xaab".match(/(a|ab)(b?)\z/).to_a
p "abcabc".index(/bc\z/), "abcabc".rindex(/bc\z/)
p "abcabc".scan(/c\z/), "abcabc".gsub(/c\z/, "!"), "abcabc".sub(/(b)(c)\z/, '\2\1')
p "ab".match?(/x?\z/), "ab" =~ /x?\z/, "" =~ /a?\z/
p "abc".match?(/\Aab\z/), "ab".match?(/\Aab\z/)

# \Z also passes before a \n that ends the subject
p "ab\n" =~ /b\Z/, "ab\n" =~ /b\n\Z/, "ab\n\n" =~ /b\Z/
p "ab\n".match(/(.)\Z/)[1], "ab\n".match(/.\Z\n/)[0]

# $ passes at the end of every line, so each line has its own window
p "ab\ncd\nef" =~ /d$/, "ab\ncd\nef".scan(/.$/), "ab\ncd\n".gsub(/.$/) { $&.upcase }
p "ab\n\ncd" =~ /^$/, "a\nb\n".index(/$/), "a\nb\n".rindex(/$/)
p "xxxxxxxxxx\nyz" =~ /x?y$/, "x\nyy" =~ /[xy]{2}$/

# a branch that ends without an assertion leaves every position in play
p "abcab" =~ /ab\z|b/, "abcab" =~ /b\z|c/, "a\nb" =~ /a$|b\z/

# a lookbehind and a word boundary read the text before the window
p "xaab" =~ /(?<=a)b\z/, "xyb" =~ /(?<=a)b\z/, "xaab" =~ /(?<!a)b\z/
p "foo bar" =~ /\bbar\z/, "foobar" =~ /\bbar\z/, "foobar" =~ /\Bbar\z/
p "ab:cd" =~ /(?<=ab:)cd\z/, "ab:cd" =~ /(?<=b:c)d$/

# characters wider than a byte: the window may begin inside one, which is
# no place a match starts
p "aéé".match(/.\z/)[0], "aéé".match(/..\z/)[0], "aéé".match(/(?<=é)é\z/)[0]
p "日本語".match(/.{2}\z/)[0], "日本語".scan(/.$/), "日本\n語\n".scan(/.$/)
p "aéb".match(/(?<=é)b\z/).pre_match, "a　".match?(/[[:blank:]]\z/)
s = "\xE3\x81".dup.force_encoding("BINARY") + "b"
p s.match?(/.b\z/n)

# $~ after a search the window answered with no match
"abc" =~ /a\z/
p $~
"abc" =~ /c\z/
p $~[0], $~.pre_match

# a long subject: the answer is the same as trying every position
line = ("word " * 400) + "end "
p line.match?(/[[:blank:]]\z/), line =~ /\s\z/, line.sub(/\s+\z/, "").size
