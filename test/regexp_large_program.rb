# A pattern whose program runs past 65535 instructions -- an alternation of
# 12,000 three-character words, each character three UTF-8 bytes -- compiles
# and matches as CRuby's does. Its jumps reach past 16 bits.

words = (0...12000).map { |i| [0x4E00 + i % 4000, 0x4E00 + (i * 7) % 4000, 0x4E00 + i / 4000].pack("U*") }
re = Regexp.new("(?:" + words.join("|") + ")!")
p re.source.size
s = "x#{words[0]}! y#{words[11999]}! z#{words[5000]}? #{words[7777]}!"
p s.scan(re).size
p s.scan(re).map(&:size)
p "nothing here" =~ re
p (s =~ re)
lit = Regexp.union(words.first(3000) + ["end"])
p "the end" =~ lit
