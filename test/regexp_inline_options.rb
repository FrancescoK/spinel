# spinel: not-cruby -- Regexp.new("[a\xE3]") below: CRuby refuses a truncated
# multi-byte character class (RegexpError), the engine taken from mruby-regexp
# reads the byte; the rest of the file answers as CRuby does.
# Inline option groups, imported from mruby-regexp: the toggle form (?i)
# applies to the rest of the enclosing group; the scoped form (?i:...) applies
# only to its body; negation (?-i) switches off. m is DOTALL (Ruby /m).

# scoped ignorecase
p(/(?i:abc)/ =~ "xABCy")
p(/(?i:abc)def/ =~ "ABCdef")
p(/(?i:abc)def/ =~ "ABCDEF")     # def outside the scope stays sensitive
# toggle: rest of the pattern
p(/a(?i)bc/ =~ "aBC")
p(/a(?i)bc/ =~ "Abc")            # before the toggle stays sensitive
# toggle inside a group does not leak past its ')'
p(/(a(?i)b)c/ =~ "aBc")
p(/(a(?i)b)c/ =~ "aBC")
# negation
p(/(?i:a(?-i:b)c)/ =~ "AbC")
p(/(?i:a(?-i:b)c)/ =~ "ABC")
# scoped dotall
p(/(?m:a.c)/ =~ "a\nc")
p(/a.c/ =~ "a\nc")
# combined and toggled off
p(/(?im:a.b)/ =~ "A\nB")
p(/(?i-m:a.b)/ =~ "A\nB")
p(/(?i-m:axb)/ =~ "AxB")

# Inline x: accepted when it is a no-op (no significant whitespace in its
# scope, e.g. a decorative (?x:foo)); a scope the /x strip would actually
# change raises loudly instead of silently diverging from CRuby.
p(/(?x:foo)/ =~ "foobar")
begin
  Regexp.new("(?x:a b)")
  puts "ws-x: compiled"
rescue RegexpError
  puts "ws-x: RegexpError"
end

# Invalid patterns raise RegexpError instead of hanging. The redundant
# `a***` compiles (CRuby warns), and so do the absence operator (?~...) and
# the conditional, which the engine carries since mruby-regexp 046c3ce22 and
# 047225c63; (?(a)b) names no group and is refused, as CRuby refuses it.
["*", "+", "?", "a***", "(?~foo)", "(?(a)b)", "(?q)a", "(?x:ab)"].each do |src|
  begin
    Regexp.new(src)
    puts "#{src}: compiled"
  rescue RegexpError
    puts "#{src}: RegexpError"
  end
end

# Truncated UTF-8 at the end of the subject: a search raises ArgumentError
# before it matches, as CRuby's does. The same bytes as ASCII-8BIT are
# searched, and must not read past the buffer under ASAN.
s = "abc\xE3"
begin
  p(/c/ =~ s)
rescue ArgumentError => e
  puts e.message
end
p(/c/ =~ s.b)
p(/z/ =~ s.b)
# truncated multi-byte leader at the end of a character class
r = Regexp.new("[a\xE3]")
p(r =~ "za")

# a multi-member non-ASCII char class (an ascending codepoint run exercises
# the contiguous-range merge in class_add_range)
r2 = Regexp.new("[あいうえお]+")
p(r2 =~ "abcいうえxyz")
p $~[0]
p(r2 =~ "abcxyz")
