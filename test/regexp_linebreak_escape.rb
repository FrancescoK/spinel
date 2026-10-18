# \R matches any linebreak, as CRuby's (?>\r\n|[\n\v\f\r\u0085  ])
# does: a CR LF pair as one, which a later failure does not split. It raised
# RegexpError. Inside a character class it is the letter R, and in a
# look-behind it is refused as CRuby refuses it.

p "a\r\nb".scan(/\R/), " x".match?(/\R/), "a\r\n\nb".split(/\R/)
p "x\r\n" =~ /\R\z/, "\r\n" =~ /\A\R\z/, "\r\n".match(/\R{2}/), "\r\r\n".match(/\R{2}/).to_a
p "R".match?(/[\R]/), "\r\n" =~ /\A\R\n\z/
p "ab\v".match?(/\R/), "\u0085".match?(/\R/), "abc".match?(/\R/)
p "a\nb".gsub(/\R/, "|"), "x\r\n\r\ny".split(/\R+/), "\r\n\n".scan(/\R/)
src = "{ |x|\n  x }"
p src.match?(/\R/), "{ |x| x }".match?(/\R/)
re = Regexp.new("a\\Rb")
p re.match?("a\nb"), re.match?("a\r\nb"), re.match?("a\n\nb")
p "x\r\ny" =~ /x(?:\R)y/, "x\ny"[/\R/]
p "xa" =~ /x(?:a|\R|b)/, "x\n" =~ /x(?:a|\R|b)/, "\n" =~ /a|\R|b/
p "A\r\n" =~ /a\R/i, "a\n" =~ /a \R/x
begin
  Regexp.new("(?<=\\R)x")
rescue RegexpError => e
  puts e.message
end
p "a\x0b".b.match?(Regexp.new("\\R".b, Regexp::NOENCODING))
